
# include this file if you want Array#where to work

module ActiveRecord
  module HashOptions
    module Enumerable
      def where(conditions = :chain)
        if :chain == conditions
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
