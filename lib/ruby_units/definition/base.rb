module RubyUnits
  module Definition
    # A base unit describes a fundamental unit for a particular system, like
    # 'meter', 'kilogram', or 'second' for SI, or 'centimeter', 'gram',
    # 'second' for CGS
    class Base
      attr_accessor :aliases,
                    :definition,
                    :display_name,
                    :kind,
                    :scalar,
                    :name,
                    :numerator,
                    :denominator

      def initialize(proxy, unit_system_abbreviation)
        @unit_system_abbreviation = unit_system_abbreviation.to_sym
        @name = proxy.attributes[:name].to_sym
        @scalar = 1
        @numerator = proxy.attributes[:numerator] || [@name]
        @denominator = []
        @kind = proxy.attributes[:kind]
        @aliases = proxy.attributes[:aliases]
        @display_name = proxy.attributes[:display_name]
        @definition = nil
      end

      def display_name
        @display_name ||= @aliases.first
      end

      def unit_system
        RubyUnits::UnitSystem.registered[@unit_system_abbreviation]
      end

      def aliases
        Set.new(@aliases).add(name.to_s).delete(nil)
      end
    end
  end
end
