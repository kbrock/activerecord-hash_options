# frozen_string_literal: true

module ActiveRecord
  module HashOptions
    # Adds where to any class
    # Most commonly, this is included into Array
    # Rhe requirement is for the class to implement #select
    module Enumerable
      def where(conditions = :chain)
        if conditions == :chain
          ActiveRecord::HashOptions::Enumerable::NotChain.new(self)
        else
          ActiveRecord::HashOptions.filter(self, conditions, false)
        end
      end

      class NotChain
        def initialize(collection)
          @collection = collection
        end

        def not(conditions = {})
          ActiveRecord::HashOptions.filter(@collection, conditions, true)
        end
      end
    end
  end
end
