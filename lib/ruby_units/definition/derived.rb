require_relative 'base'
module RubyUnits
  module Definition
    # Represents the definition of a unit composed of other units
    class Derived < Base
      def initialize(proxy, abbreviation)
        super
        @scalar = proxy.attributes[:scalar]
        @numerator = proxy.attributes[:numerator]
        @denominator = proxy.attributes[:denominator]
        @definition = proxy.attributes[:definition]
        fail ArgumentError, "Cannot define a unit using both 'numerator/denominator' and a 'definition'" if @definition && (@numerator || @denominator)
      end

      def defined_as
        @defined_as ||= definition.call
      end

      def scalar
        @scalar ||= (defined_as ? defined_as.scalar : 1)
      end

      def numerator
        @numerator ||= (defined_as ? defined_as.numerator : [])
      end

      def denominator
        @denominator ||= (defined_as ? defined_as.denominator : [])
      end

      # if we ask for kind, but the unit is defined in terms of other units,
      # call the definition and then use it.
      def kind
        @kind ||= defined_as.kind
      end
    end
  end
end
