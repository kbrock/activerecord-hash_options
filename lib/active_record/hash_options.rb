# frozen_string_literal: true

require "active_record/hash_options/version"
require "active_record/hash_options/operators"
require "active_record/hash_options/operators/regexp"
require "active_record/hash_options/helpers"
require "active_record/hash_options/enumerable"

module ActiveRecord
  module HashOptions
    # likes are case sensitive (all but sqlite - depending upon locale)
    cattr_accessor :sensitive_like, :default => true
    # likes can be case insensitive (i.e.: ILIKE and postgres)
    cattr_accessor :insensitive_like, :default => true
    # = are case sensitive (all but mysql. locales may change this)
    cattr_accessor :sensitive_compare, :default => true
    # for an insensitive equality, we can use "col LIKE value" or "LOWER(col) = value.downcase"
    cattr_accessor :use_like_for_compare, :default => false
    # use regular expressions (all but sqlite - but extensions can change this)
    cattr_accessor :use_regex, :default => true

    # convenience method to display detected values
    def self.settings
      {
        :sensitive_like       => sensitive_like,
        :insensitive_like     => insensitive_like,
        :sensitive_compare    => sensitive_compare,
        :use_regex            => use_regex,
        :use_like_for_compare => use_like_for_compare
      }
    end

    # detect settings from the database
    # please call after a database connection has been established
    def self.detect(connection, driver)
      # only need to force this for mysql - otherwise it detects strange values
      collation = connection.try(:collation) if driver.include?("mysql")

      # a like 'A' (please respect case) - returns false if respects case
      self.sensitive_like = !detect_boolean(Arel::Nodes::Matches.new(quote('a'), quote("A"), nil, true), connection, collation)
      # a like 'A' (please ignore case) - returns true if can ignore case
      self.insensitive_like = detect_boolean(Arel::Nodes::Matches.new(quote('a'), quote('A'), nil, false), connection, collation)
      # # a = 'A' - returns false if respects case
      self.sensitive_compare = !detect_boolean(Arel::Nodes::Equality.new(quote('a'), quote('A')), connection, collation)
      # a ~ a - returns true if can use regular expressions
      self.use_regex = detect_boolean(Arel::Nodes::Regexp.new(quote('a'), quote('a'), true), connection, collation)
      self.use_like_for_compare = !sensitive_like
    end

    def self.extended(mod)
      super
      ActiveRecord::HashOptions.register_my_handler(mod)
    end

    def self.inherited(mod)
      super
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

    def self.filter(scope_or_array, conditions, negate = false) # rubocop:disable Style/OptionalBooleanParameter
      if scope_or_array.kind_of?(Array) || scope_or_array.kind_of?(ActiveRecord::HashOptions::Enumerable)
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
      # rails <= 6.0, negation NOR:
      # method = :all?
      # rails >= 6.1, negation uses NAND:
      method = negate ? :any? : :all?
      array.select do |rec|
        conditions.send(method) do |name, value|
          actual_val = rec.send(name)
          case compare_array_column(actual_val, value)
          when nil # compare with nil is never true
            nil
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
          actual_val.match(value)
        end
      when Array
        if actual_val.nil?
          value.include?(nil) ? true : nil # treat as IS NULL
        else
          value.include?(actual_val)
        end
      when Range
        if actual_val.nil?
          nil
        else
          value.cover?(actual_val)
        end
      when ActiveRecord::HashOptions::GenericOp
        value.call(actual_val)
      when NilClass
        actual_val.nil? # treat as IS NULL
      else # String, Integer
        if actual_val.nil?
          nil
        else
          actual_val == value
        end
      end
    end

    def self.detect_boolean(clause, connection, collation = nil)
      clause = Arel::Nodes::SqlLiteral.new("#{clause.to_sql} COLLATE #{collation}") if collation
      sql = Arel::Nodes::SelectCore.new.tap { |sc| sc.projections << clause }
      [1, true].include?(connection.select_value(sql))
    rescue NotImplementedError
      false
    end
    private_class_method :detect_boolean

    def self.quote(str)
      Arel::Nodes.build_quoted(str)
    end
    private_class_method :quote
  end
end
