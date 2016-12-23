require "active_record/hash_options/version"
require "active_record/hash_options/operators"
require "active_record/hash_options/helpers"

module ActiveRecord
  module HashOptions
    def self.extended(mod)
      ActiveRecord::HashOptions.register_my_handler(mod)
    end

    def self.inherited(mod)
      ActiveRecord::HashOptions.register_my_handler(mod)
    end

    def self.register_my_handler(mod)
      if mod < ActiveRecord::Base && mod.kind_of?(Class)
        mod.predicate_builder.register_handler(GT, proc { |column, op| Arel::Nodes::GreaterThan.new(column, op.expression) })
        mod.predicate_builder.register_handler(LT, proc { |column, op| Arel::Nodes::LessThan.new(column, op.expression) })
        mod.predicate_builder.register_handler(GTE, proc { |column, op| Arel::Nodes::GreaterThanOrEqual.new(column, op.expression) })
        mod.predicate_builder.register_handler(LTE, proc { |column, op| Arel::Nodes::LessThanOrEqual.new(column, op.expression) })
        mod.predicate_builder.register_handler(LIKE, proc { |column, op| Arel::Nodes::Matches.new(column, Arel::Nodes.build_quoted(op.expression, column), nil, true) })
        # for postgres:
        mod.predicate_builder.register_handler(ILIKE, proc { |column, op| Arel::Nodes::Matches.new(column, Arel::Nodes.build_quoted(op.expression, column), nil, false) })
      end
    end
  end
end
