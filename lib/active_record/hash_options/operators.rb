module ActiveRecord
  module HashOptions
    GenericOp = Struct.new(:expression)

    class GT < GenericOp
      def self.arel_proc
        proc { |column, op| Arel::Nodes::GreaterThan.new(column, op.expression) }
      end
    end

    class LT < GenericOp
      def self.arel_proc
        proc { |column, op| Arel::Nodes::LessThan.new(column, op.expression) }
      end
    end

    class GTE < GenericOp
      def self.arel_proc
        proc { |column, op| Arel::Nodes::GreaterThanOrEqual.new(column, op.expression) }
      end
    end

    class LTE < GenericOp
      def self.arel_proc
        proc { |column, op| Arel::Nodes::LessThanOrEqual.new(column, op.expression) }
      end
    end

    class LIKE < GenericOp
      def self.arel_proc
        proc { |column, op| Arel::Nodes::Matches.new(column, Arel::Nodes.build_quoted(op.expression, column), nil, true) }
      end
    end

    class NOT_LIKE < LIKE
      def self.arel_proc
        proc { |column, op| Arel::Nodes::DoesNotMatch.new(column, Arel::Nodes.build_quoted(op.expression, column), nil, true) }
      end
    end

    # for postgres:

    class ILIKE < LIKE
      def self.arel_proc
        proc { |column, op| Arel::Nodes::Matches.new(column, Arel::Nodes.build_quoted(op.expression, column), nil, false) }
      end
    end

    # typically, a Regexp will go through, so this should not becalled
    # this is here to group proc for regexp with others
    class REGEXP < GenericOp
      def self.arel_proc
        proc { |column, op|  Arel::Nodes::Regexp.new(column, op, !!(op.options && Regexp::IGNORECASE))}
      end
    end
  end
end
