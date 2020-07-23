# frozen_string_literal: true
module ActiveRecord
  module HashOptions
    # Operator contains logic for producing arel for the database and acts as a lambda for ruby
    class GenericOp
      attr_accessor :expression, :expression2

      def initialize(expression, expression2 = nil)
        @expression = expression
        @expression2 = expression2
      end

      def self.quote(op_expression, column)
        if op_expression.kind_of?(String)
          Arel::Nodes.build_quoted(op_expression, column)
        else
          op_expression
        end
      end
    end

    class GT < GenericOp
      def self.arel_proc
        proc { |column, op| Arel::Nodes::GreaterThan.new(column, GenericOp.quote(op.expression, column)) }
      end

      def call(val)
        val && val > expression
      end
    end

    class LT < GenericOp
      def self.arel_proc
        proc { |column, op| Arel::Nodes::LessThan.new(column, GenericOp.quote(op.expression, column)) }
      end

      def call(val)
        val && val < expression
      end
    end

    class GTE < GenericOp
      def self.arel_proc
        proc { |column, op| Arel::Nodes::GreaterThanOrEqual.new(column, GenericOp.quote(op.expression, column)) }
      end

      def call(val)
        val && val >= expression
      end
    end

    class LTE < GenericOp
      def self.arel_proc
        proc { |column, op| Arel::Nodes::LessThanOrEqual.new(column, GenericOp.quote(op.expression, column)) }
      end

      def call(val)
        val && val <= expression
      end
    end

    class INSENSITIVE < GenericOp
      def self.arel_proc
        proc do |column, op|
          lower_column = Arel::Nodes::NamedFunction.new("LOWER", [column])
          Arel::Nodes::Equality.new(lower_column, GenericOp.quote(op.expression.downcase, column))
        end
      end

      def call(val)
        val&.downcase == expression&.downcase
      end
    end

    # Ruby doesn't have like, so I converted regex to like best I could
    # We could also do the reverse for database operations
    class LIKE < GenericOp
      def self.arel_proc
        proc { |column, op| Arel::Nodes::Matches.new(column, GenericOp.quote(op.expression, column), nil, true) }
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
      # @param extra ilike passes in Regexp::IGNORECASE
      def like_to_regex(lk, extra = nil)
        exp = lk.gsub(/([.*^$])/) {"[#{$1}]"} # escape special characters
        exp = "^#{exp}$".gsub("%", '.*').gsub("_", ".").gsub(/^\.\*/, '').gsub(/\.\*$/, '')
        Regexp.new(exp, extra)
      end
    end

    class NOT_LIKE < LIKE
      def self.arel_proc
        proc { |column, op| Arel::Nodes::DoesNotMatch.new(column, GenericOp.quote(op.expression, column), nil, true) }
      end

      def call(val)
        expression2 ||= like_to_regex(expression)
        val && val !~ expression2
      end
    end

    class ILIKE < LIKE
      def self.arel_proc
        proc { |column, op| Arel::Nodes::Matches.new(column, GenericOp.quote(op.expression, column), nil, false) }
      end

      def like_to_regex(lk)
        super(lk, Regexp::IGNORECASE)
      end
    end
  end
end
