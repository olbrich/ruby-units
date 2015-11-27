module RubyUnits
  class UnitSystem
    # used only for defining units
    class Proxy
      attr_accessor :attributes

      def initialize(name)
        @attributes = {
          name: name
        }
      end

      def definition(&block)
        fail 'Block required' unless block_given?
        @attributes[:definition] = block
      end

      %i(scalar numerator denominator kind display_name aliases).each do |meth|
        define_method :meth do |value|
          @attributes[meth] = value
        end
      end
    end
  end
end
