module ActiveRecord
  module HashOptions
    GenericOp = Struct.new(:expression, :expression2)

    class GT < GenericOp
      def self.arel_proc
        proc { |column, op| Arel::Nodes::GreaterThan.new(column, op.expression) }
      end

      def call(val)
        val && val > expression
      end
    end

    class LT < GenericOp
      def self.arel_proc
        proc { |column, op| Arel::Nodes::LessThan.new(column, op.expression) }
      end

      def call(val)
        val && val < expression
      end
    end

    class GTE < GenericOp
      def self.arel_proc
        proc { |column, op| Arel::Nodes::GreaterThanOrEqual.new(column, op.expression) }
      end

      def call(val)
        val && val >= expression
      end
    end

    class LTE < GenericOp
      def self.arel_proc
        proc { |column, op| Arel::Nodes::LessThanOrEqual.new(column, op.expression) }
      end

      def call(val)
        val && val <= expression
      end
    end

    class LIKE < GenericOp
      def self.arel_proc
        proc { |column, op| Arel::Nodes::Matches.new(column, Arel::Nodes.build_quoted(op.expression, column), nil, true) }
      end

      def call(val)
        expression2 ||= like_to_regex(expression)
        val && val =~ expression2
      end

      # escape . * ^ $ (this.gif => this[.]gif - so it won't match this_gif)
      # leave [] as [] (use by like and regular expressions)
      # convert % => .*, _ => .
      # convert ^.*abc$ => abc$
      # convert ^abc.*$ => ^abc
      def like_to_regex(lk, extra = nil)
        exp = lk.gsub(/([.*^$])/) {"[#{$1}]"} # escape special characters
        exp = "^#{exp}$".gsub("%", '.*').gsub("_", ".").gsub(/^\.\*/, '').gsub(/\.\*$/, '')
        Regexp.new(exp, extra)
      end
    end

    class NOT_LIKE < LIKE
      def self.arel_proc
        proc { |column, op| Arel::Nodes::DoesNotMatch.new(column, Arel::Nodes.build_quoted(op.expression, column), nil, true) }
      end

      def call(val)
        expression2 ||= like_to_regex(expression)
        val && val !~ expression2
      end
    end

    # for postgres:

    class ILIKE < LIKE
      def self.arel_proc
        proc { |column, op| Arel::Nodes::Matches.new(column, Arel::Nodes.build_quoted(op.expression, column), nil, false) }
      end

      def like_to_regex(lk)
        super(lk, Regexp::IGNORECASE)
      end
    end

    # typically, a Regexp will go through, so this should not becalled
    # this is here to group proc for regexp with others
    class REGEXP < GenericOp
      def self.arel_proc
        proc { |column, op|  Arel::Nodes::Regexp.new(column, op, !!(op.options && Regexp::IGNORECASE))}
      end

      def call(val)
        val && val =~ expression
      end
    end
  end
end
