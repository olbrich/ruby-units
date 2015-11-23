require 'pry'
# This class manages the collection of unit definitions used.
# Prefixes: units that only define a scalar multiplier (like milli, or dozen)
# Base Units: Units used as the fundamental units of any particular unit system
#    (like meters, kilograms, and seconds)
# Composite Units: Units composed of more than one base unit
module RubyUnits
  class DefinitionCollection
    attr_accessor :prefixes,
                  :base_units,
                  :composite_units

    def initialize
      @prefixes = {}
      @base_units = {}
      @composite_units = {}
    end

    def define(name, &block)
      fail 'Block required' unless block_given?
      proxy = RubyUnits::DefinitionProxy.new(name)
      proxy.instance_eval(&block)
      new_definition = RubyUnits::Definition.new(proxy)
      case
      when new_definition.prefix?
        @prefixes[new_definition.name] = new_definition
      when new_definition.base?
        @base_units[new_definition.name] = new_definition
      else
        @composite_units[new_definition.name] = new_definition
      end
    end
  end
end

module RubyUnits
  class Definition
    attr_accessor :name, :scalar, :kind, :numerator, :denominator
    attr_accessor :definition
    attr_accessor :aliases, :display_name

    def initialize(proxy)
      @name = proxy.attributes[:name].to_sym
      @scalar = proxy.attributes[:scalar]
      @numerator = proxy.attributes[:numerator]
      @denominator = proxy.attributes[:denominator]
      @kind = proxy.attributes[:kind]
      @aliases = proxy.attributes[:aliases]
      @display_name = proxy.attributes[:display_name] || @name.to_s
      @definition = proxy.attributes[:definition]
    end

    # we assume that if you have defined a unit in terms of other units then it
    # isn't a base unit.
    def base?
      @definition.nil? && numerator == [name] && denominator.empty? && scalar == 1
    end

    def defined_as
      @defined_as ||= definition.call if definition
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

    def aliases
      Set.new(@aliases).add(name.to_s).delete(nil)
    end

    # if we ask for kind, but the unit is defined in terms of other units, call
    # the definition and then use it.
    def kind
      @kind ||= defined_as.kind
    end

    # don't use the 'kind' method for this.  We require prefixes to declare
    # themselves as such otherwise we assume they are not.  This allows
    # them to be classified as prefixes for parsing purposes but still
    # avoid calling the definition block as long as possible.
    def prefix?
      @kind == :prefix
    end
  end
end

module RubyUnits
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

    def method_missing(name, *args, &block)
      @attributes[name.to_sym] = args[0]
    end
  end
end
