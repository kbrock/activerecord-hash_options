module ActiveRecord
  module HashOptions
    # typically, a Regexp will go through, so this should not be called
    # this is here to group proc for regexp with others
    class REGEXP < GenericOp
      def self.arel_proc
        proc do |column, op|
          mode, case_sensitive, source = convert_regex(op)
          source = Arel::Nodes.build_quoted(source)
          # case_sensitive &&= case_sensitive_database && case_sensitive_column
          # mode = "like" if mode == "=" && !case_sensitive && !use_lower_function
          case mode
          when '='
            if case_sensitive
              Arel::Nodes::Equality.new(column, source)
            else
              Arel::Nodes::Equality.new(Arel::Nodes::NamedFunction.new("LOWER", [column]), source.downcase.gsub(/\\/, ""))
            end
          when 'like'
            Arel::Nodes::Matches.new(column, source, nil, case_sensitive)
          when '~'
            Arel::Nodes::Regexp.new(column, source, case_sensitive)
          end
        end
      end

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
        source = (source[0] == "^")  ? source[1..-1] : "%#{source}"
        source = (source[-1] == "$") ? source[0..-2] : "#{source}%"

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
        source unless source =~ /[\[\]()*{}]/
      end

      # if it is simple enough, just use a regular sql like clause. or even an =
      def self.convert_regex(regex)
        case_sensitive = !(regex.options & Regexp::IGNORECASE > 0)
        source = regex_to_like(regex)

        if source.nil?
          ["~", case_sensitive, regex.source]
        elsif source !~ /([^\\]|^)[%_]/
          ["=", case_sensitive, source]
        else
          ["like", case_sensitive, source]
        end
      end
    end
  end
end
