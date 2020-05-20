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

    # typically, a Regexp will go through, so this should not becalled
    # this is here to group proc for regexp with others
    class REGEXP < GenericOp
      def self.arel_proc
        proc do |column, op|
          regexp_text = Arel::Nodes.build_quoted(op.source, column)
          case_sensitive = (op.options & Regexp::IGNORECASE == 0)
          Arel::Nodes::Regexp.new(column, regexp_text, case_sensitive)
        end
      end

      def call(val)
        val && val =~ expression
      end
    end
  end
end
