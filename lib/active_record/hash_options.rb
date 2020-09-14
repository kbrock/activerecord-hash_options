# frozen_string_literal: true
require "active_record/hash_options/version"
require "active_record/hash_options/operators"
require "active_record/hash_options/operators/regexp"
require "active_record/hash_options/helpers"
require "active_record/hash_options/enumerable"

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

    def self.filter(scope_or_array, conditions, negate = false)
      if scope_or_array.kind_of?(Array)
        filter_array(scope_or_array, conditions, negate)
      else
        filter_scope(scope_or_array, conditions, negate)
      end
    end

    def self.filter_scope(scope, conditions, negate)
      if negate
        scope.where.not(conditions)
      else
        scope.where(conditions)
      end
    end

    #  @param negate true if the value is negated (a true value is false)
    # @returns
    #   true
    #   false
    #   nil (false for both)
    def self.filter_array(array, conditions, negate)
      array.select do |rec|
        conditions.all? do |name, value|
          actual_val = rec.send(name)
          case compare_array_column(actual_val, value)
          when nil # compare with nil is never true
            false
          when false
            negate
          else
            !negate
          end
        end
      end
    end

    # returns true, false, or nil (the comparison is unknown)
    # remember, this is sql based, null == "x" and null != "x" are both false
    def self.compare_array_column(actual_val, value)
      case value
      when Regexp
        if actual_val.nil?
          nil
        else
          !!(actual_val =~ value)
        end
      when Array
        if actual_value.nil?
          if value.include?(nil) # treat as IS NULL
            true
          else
            nil
          end
        else
          !!value.include?(actual_val)
        end
      when Range
        if actual_val.nil?
          nil
        else
          !!value.cover?(actual_val)
        end
      when ActiveRecord::HashOptions::GenericOp
        value.call(actual_val)
      else # NilClass, String, Integer
        if actual_val.nil?
          if value.nil? # treat as IS NULL
            true
          else
            nil
          end
        else
          actual_val == value
        end
      end
    end
  end
end
