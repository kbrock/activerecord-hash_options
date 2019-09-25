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
        mod.predicate_builder.register_handler(GT, GT.arel_proc)
        mod.predicate_builder.register_handler(LT, LT.arel_proc)
        mod.predicate_builder.register_handler(GTE, GTE.arel_proc)
        mod.predicate_builder.register_handler(LTE, LTE.arel_proc)
        mod.predicate_builder.register_handler(INSENSITIVE, INSENSITIVE.arel_proc)
        mod.predicate_builder.register_handler(LIKE, LIKE.arel_proc)
        mod.predicate_builder.register_handler(NOT_LIKE, NOT_LIKE.arel_proc)
        # for postgres:
        mod.predicate_builder.register_handler(ILIKE, ILIKE.arel_proc)

        # NOTE: Probably want Regexp over REGEXP (e.g.: where(:name => /value/i))
        mod.predicate_builder.register_handler(Regexp, REGEXP.arel_proc)
        mod.predicate_builder.register_handler(REGEXP, REGEXP.arel_proc)
      end
    end
  end
end

class Array
  def where(options)
    select do |rec|
      options.all? do |name, value|
        actual_val = rec.send(name)
        case value
        when Regexp
          actual_val =~ value
        when Array
          value.include?(actual_val)
        when ActiveRecord::HashOptions::GenericOp
          value.call(actual_val)
        else # NilClass, String, Integer
          actual_val == value
        end
      end
    end
  end
end
