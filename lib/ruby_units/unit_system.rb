Dir['./lib/ruby_units/definition/*.rb'].each { |file| require file }

module RubyUnits
  # This class manages the collection of unit definitions used.
  # Prefixes: units that only define a scalar multiplier (like milli, or dozen)
  # Base Units: Units used as the fundamental units of any particular system
  #    (like meters, kilograms, and seconds)
  # derived Units: Units composed of more than one base unit
  class UnitSystem
    # used only for defining units
    module Proxy
      # class all other Proxy objects derive from.
      # here we define all attributes needed by each type
      class Core
        attr_accessor :attributes

        def initialize(name)
          @attributes = {
            name: name
          }
        end

        %i(display_name aliases).each do |meth|
          define_method meth do |value|
            @attributes[meth] = value
          end
        end
      end

      # A proxy class representing a Base Unit
      # which can only have a scalar of 1 and a numerator
      # equal to an array containing it's name
      class Base < Core
        %i(kind).each do |meth|
          define_method meth do |value|
            @attributes[meth] = value
          end
        end
      end

      # a proxy class representing a Prefix
      # this needs a scalar, but can't have a
      # numerator or denominator
      class Prefix < Core
        %i(scalar).each do |meth|
          define_method meth do |value|
            @attributes[meth] = value
          end
        end
      end

      # A proxy class representing a Derived Unit
      # These can be defined in terms of numerators or denominators
      # or a definition block.
      class Derived < Core
        def definition(_ = nil, &block)
          fail ArgumentError, 'Block required for definition' unless block_given?
          @attributes[:definition] = block
        end

        %i(scalar numerator denominator kind).each do |meth|
          define_method meth do |value|
            @attributes[meth] = value
          end
        end
      end
    end

    @unit_systems = {}

    def self.register(unit_system)
      fail ArgumentError, 'Not a RubyUnits::UnitSystem' unless unit_system.is_a? RubyUnits::UnitSystem
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

    # this method can be used to add additional definitions to a
    # unit system after it has been created.
    def extend(&block)
      instance_eval(&block) if block_given?
    end

    def base(name, &block)
      fail ArgumentError, 'Block required' unless block_given?
      new_definition = build_definition(:base, name, abbreviation, &block)
      check_for_ambiguous_definition(units, new_definition)
      @base_units[new_definition.name] = new_definition
    end

    def prefix(name, &block)
      fail ArgumentError, 'Block required' unless block_given?
      new_definition = build_definition(:prefix, name, abbreviation, &block)
      check_for_ambiguous_definition(prefixes, new_definition)
      @prefixes[new_definition.name] = new_definition
    end

    def derived(name, &block)
      fail ArgumentError, 'Block required' unless block_given?
      new_definition = build_definition(:derived, name, abbreviation, &block)
      check_for_ambiguous_definition(units, new_definition)
      @derived_units[new_definition.name] = new_definition
    end

    private

    def build_definition(type, name, unit_system_abbreviation, &block)
      proxy = RubyUnits::UnitSystem::Proxy.const_get(type.capitalize).new(name)
      proxy.instance_eval(&block)
      RubyUnits::Definition.const_get(type.capitalize).new(proxy, unit_system_abbreviation)
    end

    # This check will fail if we define a unit or prefix that
    # conflicts with an already defined one.
    def check_for_ambiguous_definition(collection, new_definition)
      already_used_aliases = Set.new(collection.values.map(&:aliases)).flatten & new_definition.aliases
      return if already_used_aliases.empty?
      fail "Ambiguous #{new_definition.class}: #{new_definition.name} -- Aliases #{already_used_aliases.to_a.inspect} are already in use."
    end
  end
end
