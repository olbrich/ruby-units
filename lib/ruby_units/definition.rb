class RubyUnits::Unit < Numeric
  # Handle the definition of units
  class Definition
    # @return [Array]
    attr_writer :aliases

    # @return [Symbol]
    attr_accessor :kind

    # @return [Numeric]
    attr_accessor :scalar

    # @return [Array]
    attr_accessor :numerator

    # @return [Array]
    attr_accessor :denominator

    # @return [String]
    attr_accessor :display_name

    # @example Raw definition from a hash
    #   Unit::Definition.new("rack-unit",[%w{U rack-U}, (6405920109971793/144115188075855872), :length, %w{<meter>} ])
    #
    # @example Block form
    #   Unit::Definition.new("rack-unit") do |unit|
    #     unit.aliases = %w{U rack-U}
    #     unit.definition = RubyUnits::Unit.new("7/4 inches")
    #   end
    #
    def initialize(name, definition = [])
      yield self if block_given?
      self.name     ||= name.gsub(/[<>]/, '')
      @aliases      ||= (definition[0] || [name])
      @scalar       ||= definition[1]
      @kind         ||= definition[2]
      @numerator    ||= definition[3] || RubyUnits::Unit::UNITY_ARRAY
      @denominator  ||= definition[4] || RubyUnits::Unit::UNITY_ARRAY
      @display_name ||= @aliases.first
    end

    # name of the unit
    # nil if name is not set, adds '<' and '>' around the name
    # @return [String, nil]
    # @todo refactor Unit and Unit::Definition so we don't need to wrap units with angle brackets
    def name
      "<#{@name}>" if defined?(@name) && @name
    end

    # set the name, strip off '<' and '>'
    # @param [String]
    # @return [String]
    def name=(name_value)
      @name = name_value.gsub(/[<>]/, '')
    end

    # alias array must contain the name of the unit and entries must be unique
    # @return [Array]
    def aliases
      [[@aliases], @name].flatten.compact.uniq
    end

    # define a unit in terms of another unit
    # @param [Unit] unit
    # @return [Unit::Definition]
    def definition=(unit)
      base         = unit.to_base
      @scalar      = base.scalar
      @kind        = base.kind
      @numerator   = base.numerator
      @denominator = base.denominator
      self
    end

    # is this definition for a prefix?
    # @return [Boolean]
    def prefix?
      kind == :prefix
    end

    # Is this definition the unity definition?
    # @return [Boolean]
    def unity?
      prefix? && scalar == 1
    end

    # is this a base unit?
    # units are base units if the scalar is one, and the unit is defined in terms of itself.
    # @return [Boolean]
    def base?
      (denominator     == RubyUnits::Unit::UNITY_ARRAY) &&
        (numerator       != RubyUnits::Unit::UNITY_ARRAY) &&
        (numerator.size  == 1) &&
        (scalar          == 1) &&
        (numerator.first == self.name)
    end
  end
end
