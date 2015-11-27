module RubyUnits
  # This class manages the collection of unit definitions used.
  # Prefixes: units that only define a scalar multiplier (like milli, or dozen)
  # Base Units: Units used as the fundamental units of any particular system
  #    (like meters, kilograms, and seconds)
  # derived Units: Units composed of more than one base unit
  class UnitSystem
    @unit_systems = {}

    def self.register(unit_system)
      @unit_systems[unit_system.abbreviation] = unit_system
    end

    def self.registered
      @unit_systems
    end

    def self.[](system)
      registered[system.to_sym]
    end

    attr_accessor :abbreviation,
                  :base_units,
                  :derived_units,
                  :name,
                  :prefixes

    def initialize(name, abbreviation, &block)
      @name = name
      @abbreviation = abbreviation
      @prefixes = {}
      @base_units = {}
      @derived_units = {}
      extend(&block)
      self.class.register(self)
    end

    def units
      base_units.merge(derived_units)
    end

    def extend(&block)
      instance_eval(&block) if block_given?
    end

    def check_for_ambiguous_definition(collection, new_definition)
      already_used_aliases = Set.new(collection.values.map(&:aliases)).flatten &
                             new_definition.aliases
      return if already_used_aliases.empty?
      fail "Ambiguous #{new_definition.class}: #{new_definition.name} -- Aliases #{already_used_aliases.to_a.inspect} are already in use."
    end

    def define_base(name, &block)
      fail 'Block required' unless block_given?
      proxy = RubyUnits::DefinitionProxy.new(name)
      proxy.instance_eval(&block)
      new_definition = RubyUnits::Definition::Base.new(proxy, abbreviation)
      check_for_ambiguous_definition(units, new_definition)
      @base_units[new_definition.name] = new_definition
    end

    def define_prefix(name, &block)
      fail 'Block required' unless block_given?
      proxy = RubyUnits::DefinitionProxy.new(name)
      proxy.instance_eval(&block)
      new_definition = RubyUnits::Definition::Prefix.new(proxy, abbreviation)
      check_for_ambiguous_definition(prefixes, new_definition)
      @prefixes[new_definition.name] = new_definition
    end

    def define(name, &block)
      fail 'Block required' unless block_given?
      proxy = RubyUnits::DefinitionProxy.new(name)
      proxy.instance_eval(&block)
      new_definition = RubyUnits::Definition::Derived.new(proxy, abbreviation)
      check_for_ambiguous_definition(units, new_definition)
      @derived_units[new_definition.name] = new_definition
    end
  end
end

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

      def initialize(proxy, abbreviation)
        @unit_system_abbreviation = abbreviation
        @name = proxy.attributes[:name].to_sym
        @scalar = 1
        @numerator = proxy.attributes[:numerator]
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

    # Represents the definition of a prefix like 'milli' or 'Mega'
    class Prefix < Base
      def initialize(proxy, abbreviation)
        super
        @scalar = proxy.attributes[:scalar]
        @numerator = []
        @kind = :prefix
      end
    end

    # Represents the definition of a unit composed of other units
    class Derived < Base
      def initialize(proxy, abbreviation)
        super
        @scalar = proxy.attributes[:scalar]
        @numerator = proxy.attributes[:numerator]
        @denominator = proxy.attributes[:denominator]
        @definition = proxy.attributes[:definition]
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

      # if we ask for kind, but the unit is defined in terms of other units, call
      # the definition and then use it.
      def kind
        @kind ||= defined_as.kind
      end
    end
  end
end

module RubyUnits
  # used only for defining units
  class DefinitionProxy
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
