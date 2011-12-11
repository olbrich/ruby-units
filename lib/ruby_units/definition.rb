class Unit < Numeric

  # Handle the definition of units
  class Definition
    
    attr_accessor :name
    
    # @return [Array]
    attr_accessor :aliases
    
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
    #     unit.definition = Unit("7/4 inches")
    #   end
    #
    def initialize(_name, _definition = [], &block)
      yield self if block_given?
      self.name     ||= _name.gsub(/[<>]/,'')
      @aliases      ||= _definition[0]
      @scalar       ||= _definition[1]
      @kind         ||= _definition[2]
      @numerator    ||= _definition[3] || Unit::UNITY_ARRAY
      @denominator  ||= _definition[4] || Unit::UNITY_ARRAY
      @display_name ||= @aliases.first
    end
    
    # name of the unit
    # nil if name is not set, adds '<' and '>' around the name
    # @return [String, nil]
    # @todo refactor Unit and Unit::Definition so we don't need to wrap units with angle brackets
    def name
      "<#{@name}>" if @name
    end
    
    # set the name, strip off '<' and '>'
    # @param [String]
    # @return [String]
    def name=(_name)
      @name = _name.gsub(/[<>]/,'')
    end
    
    # alias array must contain the name of the unit and entries must be unique
    # @return [Array]
    def aliases
      [[@aliases], @name].flatten.compact.uniq
    end

    # display name is the first one in the alias array
    # @todo   make this customizable and used (see issue #28)
    # @return [String]
    # def display_name
    #   aliases.first
    # end
      
    # define a unit in terms of another unit
    # @param [Unit] unit
    # @return [Unit::Definition]
    def definition=(unit)
      _base         = unit.to_base
      @scalar       = _base.scalar
      @kind         = _base.kind
      @numerator    = _base.numerator
      @denominator  = _base.denominator
      self
    end
    
    # @return [Boolean]
    def prefix?
      self.kind == :prefix
    end
    
    def unity?
      self.prefix? && self.numerator == Unit::UNITY_ARRAY && self.denominator == Unit::UNITY_ARRAY
    end
    
    # is this a base unit?
    # units are base units if the scalar is one, and the unit is defined in terms of itself.
    # @return [Boolean]
    def base?
      (self.denominator     == Unit::UNITY_ARRAY) &&
      (self.numerator       != Unit::UNITY_ARRAY) &&
      (self.numerator.size  == 1) &&
      (self.scalar          == 1) &&
      (self.numerator.first == self.name)
    end
    
    # Define this unit.  Registers it, but won't actually be used until Unit.setup is called
    # @return (see Unit.define)
    def define
      Unit.define(self)
    end
    
    # Define and register this unit
    # @return (see Unit.define!)
    def define!
      Unit.define!(self)
    end
  end
end