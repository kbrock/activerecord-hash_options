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
        val.nil? ? nil : val > expression
      end
    end

    class LT < GenericOp
      def self.arel_proc
        proc { |column, op| Arel::Nodes::LessThan.new(column, GenericOp.quote(op.expression, column)) }
      end

      def call(val)
        val.nil? ? nil : val < expression
      end
    end

    class GTE < GenericOp
      def self.arel_proc
        proc { |column, op| Arel::Nodes::GreaterThanOrEqual.new(column, GenericOp.quote(op.expression, column)) }
      end

      def call(val)
        val.nil? ? nil : val >= expression
      end
    end

    class LTE < GenericOp
      def self.arel_proc
        proc { |column, op| Arel::Nodes::LessThanOrEqual.new(column, GenericOp.quote(op.expression, column)) }
      end

      def call(val)
        val.nil? ? nil : val <= expression
      end
    end

    class INSENSITIVE < GenericOp
      def self.arel_proc
        proc do |column, op|
          if ActiveRecord::HashOptions.use_like_for_compare
            Arel::Nodes::Matches.new(column, GenericOp.quote(op.expression, column), nil, false)
          else
            lower_column = Arel::Nodes::NamedFunction.new("LOWER", [column])
            Arel::Nodes::Equality.new(lower_column, GenericOp.quote(op.expression.downcase, column))
          end
        end
      end

      def call(val)
        # a little odd to case insensitive compare with nil.
        # but it seems possible that this may come out of a regular expression translation
        val.nil? ? (expression.nil? ? true : nil) : val.downcase == expression&.downcase
      end
    end

    # Ruby doesn't have like, so use regex
    # We could also do the reverse for database operations
    # Case sensitive like
    class LIKE < GenericOp
      def self.arel_proc
        proc { |column, op| Arel::Nodes::Matches.new(column, GenericOp.quote(op.expression, column), nil, true) }
      end

      def initialize(expression)
        super(expression, like_to_regex(expression))
      end

      def call(val)
        val.nil? ? nil : !!(val =~ expression2)
      end

      # escape . * ^ $ (this.gif => this[.]gif - so it won't match this_gif)
      # leave [] as [] (use by like and regular expressions)
      # convert % => .*, _ => .
      # convert ^.*abc$ => abc$
      # convert ^abc.*$ => ^abc
      # @param extra ilike passes in Regexp::IGNORECASE
      def like_to_regex(lk, extra = nil)
        # TODO: extra ||= Regexp::IGNORECASE if !ActiveRecord::HashOptions.sensitive_like

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
        val.nil? ? nil : !!(val !~ expression2)
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

    def self.GT(*args)
      GT.new(*args)
    end

    def self.LT(*args)
      LT.new(*args)
    end

    def self.GTE(*args)
      GTE.new(*args)
    end

    def self.LTE(*args)
      LTE.new(*args)
    end

    def self.INSENSITIVE(*args)
      INSENSITIVE.new(*args)
    end

    def self.LIKE(*args)
      LIKE.new(*args)
    end

    def self.NOT_LIKE(*args)
      NOT_LIKE.new(*args)
    end

    def self.ILIKE(*args)
      ILIKE.new(*args)
    end
  end
end
