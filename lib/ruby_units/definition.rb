# frozen_string_literal: true

class RubyUnits::Unit < Numeric
  # Handle the definition of units
  # :reek:TooManyInstanceVariables - These instance variables represent the core attributes of a unit definition
  # :reek:Attribute - Setters are needed for the block-based initialization DSL
  # :reek:DataClump - name and definition are the constructor parameters passed through helper methods
  class Definition
    # @return [Symbol]
    attr_accessor :kind

    # @return [Numeric]
    attr_accessor :scalar

    # @return [Array]
    attr_accessor :numerator

    # @return [Array]
    attr_accessor :denominator

    # Unit name to be used when generating output. This MUST be a parseable
    # string or it won't be possible to round trip the unit to a String and
    # back.
    #
    # @return [String]
    # @example
    #   definition.display_name = "meter"
    attr_accessor :display_name

    # Create a new unit definition
    #
    # @param name [String] the name of the unit (angle brackets will be stripped)
    # @param definition [Array] optional array containing definition components:
    #   - definition[0] [Array<String>] array of aliases for the unit
    #   - definition[1] [Numeric] scalar conversion factor
    #   - definition[2] [Symbol] the kind of unit (e.g., :length, :mass, :time)
    #   - definition[3] [Array<String>] numerator units (in base unit form)
    #   - definition[4] [Array<String>] denominator units (in base unit form)
    # @yield [self] optional block to configure the definition using DSL
    #
    # @example Array-based definition (legacy form)
    #   Unit::Definition.new("rack-unit", [%w{U rack-U}, Rational(6405920109971793, 144115188075855872), :length, %w{<meter>}])
    #
    # @example Block-based definition (recommended)
    #   Unit::Definition.new("rack-unit") do |unit|
    #     unit.aliases = %w{U rack-U}
    #     unit.definition = RubyUnits::Unit.new("7/4 inches")
    #   end
    #
    # @example Block-based definition with explicit attributes
    #   Unit::Definition.new("electron-volt") do |unit|
    #     unit.aliases = %w{eV electron-volt}
    #     unit.scalar = 1.602e-19
    #     unit.kind = :energy
    #     unit.numerator = %w{<kilogram> <meter> <meter>}
    #     unit.denominator = %w{<second> <second>}
    #   end
    #
    def initialize(name, definition = [])
      @name = nil
      @aliases = nil
      @scalar = nil
      @kind = nil
      @numerator = nil
      @denominator = nil
      @display_name = nil
      yield self if block_given?
      set_defaults(name, definition)
    end

    # Get the unit's name with angle brackets
    #
    # nil if name is not set, adds '<' and '>' around the name
    # @return [String, nil] the unit name wrapped in angle brackets, or nil if name not set
    # @example
    #   definition.name  #=> "<meter>"
    # @todo refactor Unit and Unit::Definition so we don't need to wrap units with angle brackets
    def name
      "<#{@name}>" if @name
    end

    # Get the array of aliases for this unit
    #
    # The alias array must contain the name of the unit and entries must be unique.
    # This method combines all aliases, the name, and display_name into a unique array.
    # @return [Array<String>] unique array of all aliases, name, and display_name
    # @example
    #   definition.aliases  #=> ["m", "meter", "meters", "metre", "metres"]
    def aliases
      [[@aliases], @name, @display_name].flatten.compact.uniq
    end

    # Set the aliases for this unit
    # @!attribute [w] aliases
    # @param value [Array<String>] array of string aliases
    # @return [Array<String>]
    # @example
    #   definition.aliases = %w{foo bar baz}
    attr_writer :aliases

    # Set the unit's name (angle brackets will be stripped)
    # @param name_value [String] the name to assign (angle brackets will be removed)
    # @return [String] the name without angle brackets
    # @example
    #   definition.name = "<meter>"  # stores as "meter"
    def name=(name_value)
      @name = name_value.gsub(/[<>]/, "")
    end

    # Define a unit in terms of another unit
    #
    # This is a convenience method that allows you to specify a unit definition
    # using another Unit object. It will extract the base unit properties from
    # the provided unit and assign them to this definition.
    #
    # @param unit [RubyUnits::Unit] a unit object to use as the definition source
    # @return [RubyUnits::Unit::Definition] self
    # @example
    #   definition.definition = RubyUnits::Unit.new("7/4 inches")
    #   # This will set scalar, kind, numerator, and denominator based on the base unit representation
    def definition=(unit)
      base = unit.to_base
      @scalar = base.scalar
      @kind = base.kind
      @numerator = base.numerator
      @denominator = base.denominator
    end

    # Check if this definition represents a prefix
    # @return [Boolean] true if this is a prefix definition
    # @example
    #   kilo_definition.prefix?  #=> true
    #   meter_definition.prefix? #=> false
    def prefix? = kind == :prefix

    # Check if this definition is the unity definition (dimensionless with scalar = 1)
    # @return [Boolean] true if this is the unity (dimensionless) prefix definition
    # @example
    #   unity_definition.unity?  #=> true
    #   kilo_definition.unity?   #=> false
    def unity? = prefix? && scalar == 1

    # Check if this is a base unit definition
    #
    # Units are base units if:
    # - The scalar is exactly 1
    # - The denominator is the unity array (dimensionless)
    # - The numerator has exactly one element
    # - The numerator references itself (e.g., meter is defined in terms of <meter>)
    #
    # @return [Boolean] true if this is a base unit definition
    # @example
    #   meter_definition.base?  #=> true (defined as 1 <meter>)
    #   foot_definition.base?   #=> false (defined in terms of meters)
    def base?
      return false unless scalar == 1
      return false unless single_numerator?
      return false unless unity_denominator?

      numerator.first == name
    end

    private

    # Set default values for attributes from definition array
    # @param name [String] the unit name
    # @param definition [Array] array of definition values
    # @return [void]
    def set_defaults(name, definition)
      assign_name(name)
      set_attributes_from_definition(name, definition)
    end

    # Set the unit name if not already set
    # @param name [String] the unit name
    # @return [void]
    def assign_name(name)
      self.name ||= name.gsub(/[<>]/, "")
    end

    # Set attributes from the definition array
    # @param name [String] the unit name (used as fallback for aliases)
    # @param definition [Array] array of definition values
    # @return [void]
    # :reek:TooManyStatements - This method sets multiple related attributes from the definition
    def set_attributes_from_definition(name, definition)
      @aliases = @aliases || definition[0] || [name]
      @scalar ||= definition[1]
      @kind ||= definition[2]
      @numerator = @numerator || definition[3] || RubyUnits::Unit::UNITY_ARRAY
      @denominator = @denominator || definition[4] || RubyUnits::Unit::UNITY_ARRAY
      @display_name ||= @aliases.first # rubocop:disable Naming/MemoizedInstanceVariableName
    end

    # Check if denominator is the unity array
    # @return [Boolean]
    def unity_denominator?
      denominator == RubyUnits::Unit::UNITY_ARRAY
    end

    # Check if numerator is not unity and has exactly one element
    # @return [Boolean]
    def single_numerator?
      numerator != RubyUnits::Unit::UNITY_ARRAY && numerator.size == 1
    end
  end
end
