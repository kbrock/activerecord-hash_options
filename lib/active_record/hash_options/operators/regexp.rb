module ActiveRecord
  module HashOptions
    class REGEXP < GenericOp
      def self.arel_proc
        proc do |column, op|
          regexp_text = Arel::Nodes.build_quoted(op.source, column)
          case_sensitive = (op.options & Regexp::IGNORECASE == 0)
          Arel::Nodes::Regexp.new(column, regexp_text, case_sensitive)
        end
      end

      def call(val)
        val && val =~ expression
      end
    end
  end
end
