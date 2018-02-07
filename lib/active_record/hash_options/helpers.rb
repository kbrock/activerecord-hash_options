module ActiveRecord
  module HashOptions
    module Helpers
      def gt(val); ActiveRecord::HashOptions::GT.new(val); end
      def lt(val); ActiveRecord::HashOptions::LT.new(val); end
      def gte(val); ActiveRecord::HashOptions::GTE.new(val); end
      def lte(val); ActiveRecord::HashOptions::LTE.new(val); end

      def starts_with(val) ; ActiveRecord::HashOptions::LIKE.new("#{val}%"); end
      def ends_with(val) ; ActiveRecord::HashOptions::LIKE.new("%#{val}"); end
      #def includes(val) ; ActiveRecord::HashOptions::LIKE.new("%#{val}%"); end
      def not_like(val) ; ActiveRecord::HashOptions::NOT_LIKE.new(val); end
      def like(val); ActiveRecord::HashOptions::LIKE.new(val); end
      def ilike(val); ActiveRecord::HashOptions::ILIKE.new(val); end
      def negate(val = nil); ActiveRecord::HashOptions::NEGATE.new(val); end
    end
  end
end

# see MiqExpression#to_arel
#SEE https://github.com/ManageIQ/manageiq/pull/8994/files
