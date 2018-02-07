module ActiveRecord
  module HashOptions
    GenericOp = Struct.new(:expression)

    class GT < GenericOp; end
    class LT < GenericOp; end
    class GTE < GenericOp; end
    class LTE < GenericOp; end

    class LIKE < GenericOp; end
    class NOT_LIKE < GenericOp; end
    class ILIKE < GenericOp; end
    class NEGATE < GenericOp; end
  end
end
