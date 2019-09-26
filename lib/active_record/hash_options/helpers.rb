# frozen_string_literal: true
module ActiveRecord
  module HashOptions
    module Helpers
      # numeric
      def gt(val); ActiveRecord::HashOptions::GT.new(val); end
      def lt(val); ActiveRecord::HashOptions::LT.new(val); end
      def gte(val); ActiveRecord::HashOptions::GTE.new(val); end
      def lte(val); ActiveRecord::HashOptions::LTE.new(val); end
      def neq(val); ActiveRecord::HashOptions::NEQ.new(val); end

      # string
      def insensitive(val); ActiveRecord::HashOptions::INSENSITIVE.new(val); end

      def starts_with(val) ; ActiveRecord::HashOptions::LIKE.new("#{val}%"); end
      def ends_with(val) ; ActiveRecord::HashOptions::LIKE.new("%#{val}"); end
      def contains(val) ; ActiveRecord::HashOptions::LIKE.new("%#{val}%"); end
      def not_like(val) ; ActiveRecord::HashOptions::NOT_LIKE.new(val); end
      def like(val); ActiveRecord::HashOptions::LIKE.new(val); end
      def ilike(val); ActiveRecord::HashOptions::ILIKE.new(val); end
    end
  end
end
