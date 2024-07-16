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

      def cmp(val)
        return nil if val.nil? || expression.nil?

        yield(val, expression)
      end
    end

    class GT < GenericOp
      def self.arel_proc
        proc { |column, op| op.expression.nil? ? Arel::Nodes::False.new : Arel::Nodes::GreaterThan.new(column, GenericOp.quote(op.expression, column)) }
      end

      def call(val)
        cmp(val) { |a, b| a > b }
      end
    end

    class LT < GenericOp
      def self.arel_proc
        proc { |column, op| op.expression.nil? ? Arel::Nodes::False.new : Arel::Nodes::LessThan.new(column, GenericOp.quote(op.expression, column)) }
      end

      def call(val)
        cmp(val) { |a, b| a < b }
      end
    end

    class GTE < GenericOp
      def self.arel_proc
        proc { |column, op| op.expression.nil? ? Arel::Nodes::False.new : Arel::Nodes::GreaterThanOrEqual.new(column, GenericOp.quote(op.expression, column)) }
      end

      def call(val)
        cmp(val) { |a, b| a >= b }
      end
    end

    class LTE < GenericOp
      def self.arel_proc
        proc { |column, op| op.expression.nil? ? Arel::Nodes::False.new : Arel::Nodes::LessThanOrEqual.new(column, GenericOp.quote(op.expression, column)) }
      end

      def call(val)
        cmp(val) { |a, b| a <= b }
      end
    end

    class INSENSITIVE < GenericOp
      def self.arel_proc
        proc do |column, op|
          REGEXP.gen_sql(column, "=", false, op.expression)
        end
      end

      def call(val)
        # a little odd to case insensitive compare with nil
        # both nil is treated as (null) IS NULL
        return true if val.nil? && expression.nil?

        cmp(val) { |a, b| a.downcase == b.downcase }
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
        cmp(val) { |a, b| expression2.match?(a) }
      end

      # escape . * ^ $ (this.gif => this[.]gif - so it won't match this_gif)
      # leave [] as [] (use by like and regular expressions)
      # convert % => .*, _ => .
      # convert ^.*abc$ => abc$
      # convert ^abc.*$ => ^abc
      # @param extra ilike passes in Regexp::IGNORECASE
      def like_to_regex(expression, extra = nil)
        # TODO: extra ||= Regexp::IGNORECASE if !ActiveRecord::HashOptions.sensitive_like

        exp = expression.gsub(/([.*^$])/) { "[#{$1}]" } # escape special characters
        exp = "^#{exp}$".gsub("%", '.*').tr("_", ".").gsub(/^\.\*/, '').gsub(/\.\*$/, '')
        Regexp.new(exp, extra)
      end
    end

    class NOT_LIKE < LIKE # rubocop:disable Naming/ClassAndModuleCamelCase
      def self.arel_proc
        proc { |column, op| Arel::Nodes::DoesNotMatch.new(column, GenericOp.quote(op.expression, column), nil, true) }
      end

      def call(val)
        cmp(val) { |a, b| !expression2.match?(a) }
      end
    end

    class ILIKE < LIKE
      def self.arel_proc
        proc { |column, op| Arel::Nodes::Matches.new(column, GenericOp.quote(op.expression, column), nil, false) }
      end

      def like_to_regex(expression)
        super(expression, Regexp::IGNORECASE)
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
