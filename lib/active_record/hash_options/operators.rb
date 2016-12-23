module ActiveRecord
  module HashOptions
    GenericOp = Struct.new(:expression)

    class GT < GenericOp; end
    class LT < GenericOp; end
    class GTE < GenericOp; end
    class LTE < GenericOp; end

    class LIKE < GenericOp; end
    class ILIKE < GenericOp; end
  end
end
