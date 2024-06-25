module ActiveRecord
  module HashOptions
    # typically, a Regexp will go through, so this should not be called
    # this is here to group proc for regexp with others
    class REGEXP < GenericOp
      def self.arel_proc
        proc do |column, op|
          mode, case_sensitive, source = convert_regex(op)
          mode = "like" if mode == "=" && !case_sensitive && ActiveRecord::HashOptions.use_like_for_compare
          # when sensitive_compare == false, we do not respect case_sensitive for equality
          # good: we can skip the fn hack. bad: we can never get simple equality working
          mode = "fn"   if mode == "=" && !case_sensitive && ActiveRecord::HashOptions.sensitive_compare

          case mode
          when '='
            Arel::Nodes::Equality.new(column, Arel::Nodes.build_quoted(source))
          when 'fn'
            Arel::Nodes::Equality.new(Arel::Nodes::NamedFunction.new("LOWER", [column]), Arel::Nodes.build_quoted(source.downcase.delete("\\")))
          when 'like'
            # NOTE: when ActiveRecord::HashOptions.sensitive_like is false, case_sensitive is ignored and basically false
            Arel::Nodes::Matches.new(column, Arel::Nodes.build_quoted(source), nil, case_sensitive)
          when '~'
            Arel::Nodes::Regexp.new(column, Arel::Nodes.build_quoted(source), case_sensitive)
          end
        end
      end

      # This responds to where(:col => REGEXP.new(/exp/))
      # But in truth users would use where(:col => /exp/)
      # So this is for completeness of interface and isn't really usable
      def call(val)
        val && val =~ expression
      end

      # convert a regexp to a string if possible
      # the order of the operations matter so you don't double convert some phrases
      # in regex: wildcards: .,.* escaping: \,[], please_escape: .,*
      # in like:  wildcards: _,%  escaping: \ (some databases support [] - but punting for now)
      #
      # currently can't handle {}, (), [] (with more than 1 character) (non .)*
      def self.regex_to_like(regex)
        source = regex.source

        # .* (any number of any character) is ok, but {specific}* (any number of a particular letter is not ok)
        # [.] to escape a single character is ok (e.g. '.' or '*') - but any other use is not ok in postgres
        return if source =~ /([^.]\*|\[.{2,}\])/

        # convert anchors into wild characters
        source = source[0] == "^"  ? source[1..] : "%#{source}"
        source = source[-1] == "$" ? source[0..-2] : "#{source}%"

        # don't want to modify the regex, and unfreeze the anchor conversions
        source = source.dup

        # escape _, % unless already being escaped
        # convert [] escaping single letter => backslash escaping
        source.gsub!(/\[(.)\]/) { "\\#{$1}" }
        # convert .* (any number of any characters) => %
        source.gsub!('.*', '%')
        # convert . => _ unless already being escaped
        # to be honest, we probably don't use this and it is probably a bug in our source
        source.gsub!(/(?<![\\])\./, '_')
        # unescape \., \* -- they don't need to be escaped in sql
        source.gsub!(/(\\)([.*])/) { $2 }
        # condense multiple %'s
        source.gsub!(/(?<![\\])%%+/, '%')
        # can leave '\.' escaped, but fix []'
        # only suggest a like or equals if we've removed all regular expression stuff
        source unless /[\[\]()*{}]/.match?(source)
      end

      # if it is simple enough, just use a regular sql like clause. or even an =
      def self.convert_regex(regex)
        # this line is part of the where(:col => REGEXP.new()) interface compatibility:
        regex = regex.expression if regex.kind_of?(self)

        case_sensitive = !(regex.options & Regexp::IGNORECASE > 0) # rubocop:disable Style/InverseMethods
        source = regex_to_like(regex)

        if source.nil?
          ["~", case_sensitive, regex.source]
        elsif !/([^\\]|^)[%_]/.match?(source)
          ["=", case_sensitive, source]
        else
          ["like", case_sensitive, source]
        end
      end
    end
  end
end
