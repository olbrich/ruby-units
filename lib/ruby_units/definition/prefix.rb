require_relative 'base'
module RubyUnits
  module Definition
    # Represents the definition of a prefix like 'milli' or 'Mega'
    class Prefix < Base
      def initialize(proxy, abbreviation)
        super
        @scalar = proxy.attributes[:scalar]
        @numerator = []
        @kind = :prefix
      end
    end
  end
end
