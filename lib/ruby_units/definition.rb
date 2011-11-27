# @example
#   Feed it a raw definition
#   Unit::Definition.new("rack-unit",[%w{U rack-U}, (6405920109971793/144115188075855872), :length, %w{<meter>} ])
#   or
#   Unit::Definition.new("rack-unit") do
#     aliases = %w{U rack-U}
#     scalar = (6405920109971793/144115188075855872)
#     numerator = %w{<meter>}
#     kind = :length
#   end
#   or
#   rack_unit = Unit::Definition.new("rack-unit") do
#     aliases = %w{U rack-U}
#     definition = Unit("7/4 in")
#     prefix = false
#   end
#
#   Unit.define(rack_unit)
#   Unit.definition('rack-unit) # => return a copy of Unit::Definition
#
class Unit < Numeric
  class Definition
    attr_accessor :name
    attr_accessor :aliases
    attr_accessor :kind
    attr_accessor :scalar
    attr_accessor :numerator
    attr_accessor :denominator
    attr_accessor :base
    
    def initialize(_name, _definition = [], &block)
      yield self if block_given?
      self.name    ||= _name.gsub(/[<>]/,'')
      @aliases     ||= _definition[0]
      @scalar      ||= _definition[1]
      @kind        ||= _definition[2]
      @numerator   ||= _definition[3] || Unit::UNITY_ARRAY
      @denominator ||= _definition[4] || Unit::UNITY_ARRAY
      @base        ||= false
    end
    
    def name
      "<#{@name}>" if @name
    end
    
    def name=(_name)
      @name = _name.gsub(/[<>]/,'')
    end
    
    def aliases
      [[@aliases], @name].flatten.compact.uniq
    end

    def display_name
      aliases.first
    end
    
    def definition=(unit)
      _base         = unit.to_base
      @scalar       = _base.scalar
      @kind         = _base.kind
      @numerator    = _base.numerator
      @denominator  = _base.denominator
    end
    
    def prefix?
      self.kind == :prefix
    end
    
    def base?
      @base
    end
    
  end
end