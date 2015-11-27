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
