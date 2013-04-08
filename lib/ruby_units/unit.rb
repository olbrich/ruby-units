# encoding: utf-8
require 'date'
if RUBY_VERSION < "1.9"
  # :nocov_19:
  require 'parsedate'
  require 'rational'
  # :nocov_19:
end
# Copyright 2006-2012
#
# @author Kevin C. Olbrich, Ph.D.
# @see https://github.com/olbrich/ruby-units
#
# @note The accuracy of unit conversions depends on the precision of the conversion factor.
#   If you have more accurate estimates for particular conversion factors, please send them
#   to me and I will incorporate them into the next release.  It is also incumbent on the end-user
#   to ensure that the accuracy of any conversions is sufficient for their intended application.
#
# While there are a large number of unit specified in the base package,
# there are also a large number of units that are not included.
# This package covers nearly all SI, Imperial, and units commonly used
# in the United States. If your favorite units are not listed here, file an issue on github.
#
# To add or override a unit definition, add a code block like this..
# @example Define a new unit
#  Unit.define("foobar") do |unit|
#    unit.aliases    = %w{foo fb foo-bar}
#    unit.definition = Unit("1 baz")
#  end
#
# @todo fix class variables so they conform to standard naming conventions and refactor away as many of them as possible
# @todo pull caching out into its own class
# @todo refactor internal representation of units
# @todo method to determine best natural prefix
class Unit < Numeric
  VERSION            = Unit::Version::STRING
  @@definitions      = {}
  @@PREFIX_VALUES    = {}
  @@PREFIX_MAP       = {}
  @@UNIT_MAP         = {}
  @@UNIT_VALUES      = {}
  @@UNIT_REGEX       = nil
  @@UNIT_MATCH_REGEX = nil
  UNITY              = '<1>'
  UNITY_ARRAY        = [UNITY]
  FEET_INCH_REGEX    = /(\d+)\s*(?:'|ft|feet)\s*(\d+)\s*(?:"|in|inches)/
  TIME_REGEX         = /(\d+)*:(\d+)*:*(\d+)*[:,]*(\d+)*/
  LBS_OZ_REGEX       = /(\d+)\s*(?:#|lbs|pounds|pound-mass)+[\s,]*(\d+)\s*(?:oz|ounces)/
  SCI_NUMBER         = %r{([+-]?\d*[.]?\d+(?:[Ee][+-]?)?\d*)}
  RATIONAL_NUMBER    = /\(?([+-]?\d+)\/(\d+)\)?/
  COMPLEX_NUMBER     = /#{SCI_NUMBER}?#{SCI_NUMBER}i\b/
  NUMBER_REGEX       = /#{SCI_NUMBER}*\s*(.+)?/
  UNIT_STRING_REGEX  = /#{SCI_NUMBER}*\s*([^\/]*)\/*(.+)*/
  TOP_REGEX          = /([^ \*]+)(?:\^|\*\*)([\d-]+)/
  BOTTOM_REGEX       = /([^* ]+)(?:\^|\*\*)(\d+)/
  UNCERTAIN_REGEX    = /#{SCI_NUMBER}\s*\+\/-\s*#{SCI_NUMBER}\s(.+)/
  COMPLEX_REGEX      = /#{COMPLEX_NUMBER}\s?(.+)?/
  RATIONAL_REGEX     = /#{RATIONAL_NUMBER}\s?(.+)?/
  KELVIN             = ['<kelvin>']
  FAHRENHEIT         = ['<fahrenheit>']
  RANKINE            = ['<rankine>']
  CELSIUS            = ['<celsius>']
  @@TEMP_REGEX       = nil
  SIGNATURE_VECTOR = [
                      :length,
                      :time,
                      :temperature,
                      :mass,
                      :current,
                      :substance,
                      :luminosity,
                      :currency,
                      :memory,
                      :angle
                      ]
  @@KINDS = {
    -312078       =>  :elastance,
    -312058       =>  :resistance,
    -312038       =>  :inductance,
    -152040       =>  :magnetism,
    -152038       =>  :magnetism,
    -152058       =>  :potential,
    -7997         =>  :specific_volume,
    -79           =>  :snap,
    -59           =>  :jolt,
    -39           =>  :acceleration,
    -38           =>  :radiation,
    -20           =>  :frequency,
    -19           =>  :speed,
    -18           =>  :viscosity,
    -17           =>  :volumetric_flow,
    -1            =>  :wavenumber,
    0             =>  :unitless,
    1             =>  :length,
    2             =>  :area,
    3             =>  :volume,
    20            =>  :time,
    400           =>  :temperature,
    7941          =>  :yank,
    7942          =>  :power,
    7959          =>  :pressure,
    7962          =>  :energy,
    7979          =>  :viscosity,
    7961          =>  :force,
    7981          =>  :momentum,
    7982          =>  :angular_momentum,
    7997          =>  :density,
    7998          =>  :area_density,
    8000          =>  :mass,
    152020        =>  :radiation_exposure,
    159999        =>  :magnetism,
    160000        =>  :current,
    160020        =>  :charge,
    312058        =>  :resistance,
    312078        =>  :capacitance,
    3199980       =>  :activity,
    3199997       =>  :molar_concentration,
    3200000       =>  :substance,
    63999998      =>  :illuminance,
    64000000      =>  :luminous_power,
    1280000000    =>  :currency,
    25600000000   =>  :memory,
    511999999980  =>  :angular_velocity,
    512000000000  =>  :angle
    }
  @@cached_units = {}
  @@base_unit_cache = {}

  # setup internal arrays and hashes
  # @return [true]
  def self.setup
    self.clear_cache
    @@PREFIX_VALUES    = {}
    @@PREFIX_MAP       = {}
    @@UNIT_VALUES      = {}
    @@UNIT_MAP         = {}
    @@UNIT_REGEX       = nil
    @@UNIT_MATCH_REGEX = nil
    @@PREFIX_REGEX     = nil

    @@definitions.each do |name, definition|
      self.use_definition(definition)
    end

    Unit.new(1)
    return true
  end


  # determine if a unit is already defined
  # @param [String] unit
  # @return [Boolean]
  def self.defined?(unit)
    return @@UNIT_VALUES.keys.include?("<#{unit}>")
  end

  # return the unit definition for a unit
  # @param [String] unit
  # @return [Unit::Definition, nil]
  def self.definition(_unit)
    unit = (_unit =~ /^<.+>$/) ? _unit : "<#{_unit}>"
    return @@definitions[unit]
  end

  # return a list of all defined units
  # @return [Array]
  def self.definitions
    return @@definitions
  end

  # @param  [Unit::Definition|String] unit_definition
  # @param  [Block] block
  # @return [Unit::Definition]
  # @raise  [ArgumentError] when passed a non-string if using the block form
  # Unpack a unit definition and add it to the array of defined units
  #
  # @example Block form
  #   Unit.define('foobar') do |foobar|
  #     foobar.definition = Unit("1 baz")
  #   end
  #
  # @example Unit::Definition form
  #   unit_definition = Unit::Definition.new("foobar") {|foobar| foobar.definition = Unit("1 baz")}
  #   Unit.define(unit_definition)
  def self.define(unit_definition, &block)
    if block_given?
      raise ArgumentError, "When using the block form of Unit.define, pass the name of the unit" unless unit_definition.instance_of?(String)
      unit_definition = Unit::Definition.new(unit_definition, &block)
    end
    Unit.definitions[unit_definition.name] = unit_definition
    Unit.use_definition(unit_definition)
    return unit_definition
  end

  # @param [String] name Name of unit to redefine
  # @param [Block] block
  # @raise [ArgumentError] if a block is not given
  # @yield [Unit::Definition]
  # @return (see Unit.define)
  # Get the definition for a unit and allow it to be redefined
  def self.redefine!(name, &block)
    raise ArgumentError, "A block is required to redefine a unit" unless block_given?
    unit_definition = self.definition(name)
    yield unit_definition
    self.define(unit_definition)
  end

  # @param [String] name of unit to undefine
  # @return (see Unit.setup)
  # Undefine a unit.  Will not raise an exception for unknown units.
  def self.undefine!(unit)
    @@definitions.delete("<#{unit}>")
    Unit.setup
  end

  include Comparable

  # @return [Numeric]
  attr_accessor :scalar

  # @return [Array]
  attr_accessor :numerator

  # @return [Array]
  attr_accessor :denominator

  # @return [Integer]
  attr_accessor :signature

  # @return [Numeric]
  attr_accessor :base_scalar

  # @return [Array]
  attr_accessor :base_numerator

  # @return [Array]
  attr_accessor :base_denominator

  # @return [String]
  attr_accessor :output

  # @return [String]
  attr_accessor :unit_name

  # needed to make complex units play nice -- otherwise not detected as a complex_generic
  # @param [Class]
  # @return [Boolean]
  def kind_of?(klass)
    self.scalar.kind_of?(klass)
  end

  # Used to copy one unit to another
  # @param [Unit] from Unit to copy definition from
  # @return [Unit]
  def copy(from)
    @scalar      = from.scalar
    @numerator   = from.numerator
    @denominator = from.denominator
    @is_base     = from.is_base?
    @signature   = from.signature
    @base_scalar = from.base_scalar
    @unit_name   = from.unit_name rescue nil
    return self
  end

  if RUBY_VERSION < "1.9"
    # :nocov_19:

    # a list of properties to emit to yaml
    # @return [Array]
    def to_yaml_properties
      %w{@scalar @numerator @denominator @signature @base_scalar}
    end

    # basically a copy of the basic to_yaml.  Needed because otherwise it ends up coercing the object to a string
    # before YAML'izing it.
    # @param [Hash] opts
    # @return [String]
    def to_yaml( opts = {} )
      YAML::quick_emit( object_id, opts ) do |out|
        out.map( taguri, to_yaml_style ) do |map|
          for m in to_yaml_properties do
            map.add( m[1..-1], instance_variable_get( m ) )
          end
        end
      end
    end
    # :nocov_19:
  end

  # Create a new Unit object.  Can be initialized using a String, a Hash, an Array, Time, DateTime
  #
  # @example Valid options include:
  #  "5.6 kg*m/s^2"
  #  "5.6 kg*m*s^-2"
  #  "5.6 kilogram*meter*second^-2"
  #  "2.2 kPa"
  #  "37 degC"
  #  "1"  -- creates a unitless constant with value 1
  #  "GPa"  -- creates a unit with scalar 1 with units 'GPa'
  #  "6'4\"""  -- recognized as 6 feet + 4 inches
  #  "8 lbs 8 oz" -- recognized as 8 lbs + 8 ounces
  #  [1, 'kg']
  #  {:scalar => 1, :numerator=>'kg'}
  #
  # @param [Unit,String,Hash,Array,Date,Time,DateTime] options
  # @return [Unit]
  # @raise [ArgumentError] if absolute value of a temperature is less than absolute zero
  # @raise [ArgumentError] if no unit is specified
  # @raise [ArgumentError] if an invalid unit is specified
  def initialize(*options)
    @scalar      = nil
    @base_scalar = nil
    @unit_name   = nil
    @signature   = nil
    @output      = { }
    raise ArgumentError, "Invalid Unit Format" if options[0].nil?
    if options.size == 2
      # options[0] is the scalar
      # options[1] is a unit string
      begin
        cached = @@cached_units[options[1]] * options[0]
        copy(cached)
      rescue
        initialize("#{options[0]} #{(options[1].units rescue options[1])}")
      end
      return
    end
    if options.size == 3
      options[1] = options[1].join if options[1].kind_of?(Array)
      options[2] = options[2].join if options[2].kind_of?(Array)
      begin
        cached = @@cached_units["#{options[1]}/#{options[2]}"] * options[0]
        copy(cached)
      rescue
        initialize("#{options[0]} #{options[1]}/#{options[2]}")
      end
      return
    end

    case options[0]
      when Unit
        copy(options[0])
        return
      when Hash
        @scalar      = options[0][:scalar] || 1
        @numerator   = options[0][:numerator] || UNITY_ARRAY
        @denominator = options[0][:denominator] || UNITY_ARRAY
        @signature   = options[0][:signature]
      when Array
        initialize(*options[0])
        return
      when Numeric
        @scalar    = options[0]
        @numerator = @denominator = UNITY_ARRAY
      when Time
        @scalar      = options[0].to_f
        @numerator   = ['<second>']
        @denominator = UNITY_ARRAY
      when DateTime, Date
        @scalar      = options[0].ajd
        @numerator   = ['<day>']
        @denominator = UNITY_ARRAY
      when /^\s*$/
        raise ArgumentError, "No Unit Specified"
      when String
        parse(options[0])
      else
        raise ArgumentError, "Invalid Unit Format"
    end
    self.update_base_scalar
    raise ArgumentError, "Temperatures must not be less than absolute zero" if self.is_temperature? &&  self.base_scalar < 0
    unary_unit = self.units || ""
    if options.first.instance_of?(String)
      opt_scalar, opt_units = Unit.parse_into_numbers_and_units(options[0])
      unless @@cached_units.keys.include?(opt_units) || (opt_units =~ /(#{Unit.temp_regex})|(pounds|lbs[ ,]\d+ ounces|oz)|('\d+")|(ft|feet[ ,]\d+ in|inch|inches)|%|(#{TIME_REGEX})|i\s?(.+)?|&plusmn;|\+\/-/)
        @@cached_units[opt_units] = (self.scalar == 1 ? self : opt_units.unit) if opt_units && !opt_units.empty?
      end
    end
    unless @@cached_units.keys.include?(unary_unit) || (unary_unit =~ /#{Unit.temp_regex}/) then
      @@cached_units[unary_unit] = (self.scalar == 1 ? self : unary_unit.unit)
    end
    [@scalar, @numerator, @denominator, @base_scalar, @signature, @is_base].each {|x| x.freeze}
    return self
  end

  # @todo: figure out how to handle :counting units.  This method should probably return :counting instead of :unitless for 'each'
  # return the kind of the unit (:mass, :length, etc...)
  # @return [Symbol]
  def kind
    return @@KINDS[self.signature]
  end

  # @private
  # @return [Hash]
  def self.cached
    return @@cached_units
  end

  # @private
  # @return [true]
  def self.clear_cache
    @@cached_units    = {}
    @@base_unit_cache = {}
    Unit.new(1)
    return true
  end

  # @private
  # @return [Hash]
  def self.base_unit_cache
    return @@base_unit_cache
  end

  # @example parse strings
  #   "1 minute in seconds"
  # @param [String] input
  # @return [Unit]
  def self.parse(input)
    first, second = input.scan(/(.+)\s(?:in|to|as)\s(.+)/i).first
    return second.nil? ? first.unit : first.unit.convert_to(second)
  end

  # @return [Unit]
  def to_unit
    self
  end
  alias :unit :to_unit

  # Is this unit in base form?
  # @return [Boolean]
  def is_base?
    return @is_base if defined? @is_base
    @is_base = (@numerator + @denominator).compact.uniq.
                                            map {|unit| Unit.definition(unit)}.
                                            all? {|element| element.unity? || element.base? }
    return @is_base
  end
  alias :base? :is_base?

  # convert to base SI units
  # results of the conversion are cached so subsequent calls to this will be fast
  # @return [Unit]
  # @todo this is brittle as it depends on the display_name of a unit, which can be changed
  def to_base
    return self if self.is_base?
    if @@UNIT_MAP[self.units] =~ /\A<(?:temp|deg)[CRF]>\Z/
      if RUBY_VERSION < "1.9"
        # :nocov_19:
        @signature = @@KINDS.index(:temperature)
        # :nocov_19:
      else
        #:nocov:
        @signature = @@KINDS.key(:temperature)
        #:nocov:
      end
      base = case
      when self.is_temperature?
        self.convert_to('tempK')
      when self.is_degree?
        self.convert_to('degK')
      end
      return base
    end

    cached = ((@@base_unit_cache[self.units] * self.scalar) rescue nil)
    return cached if cached

    num = []
    den = []
    q = 1
    for unit in @numerator.compact do
      if @@PREFIX_VALUES[unit]
        q *= @@PREFIX_VALUES[unit]
      else
        q *= @@UNIT_VALUES[unit][:scalar] if @@UNIT_VALUES[unit]
        num << @@UNIT_VALUES[unit][:numerator] if @@UNIT_VALUES[unit] && @@UNIT_VALUES[unit][:numerator]
        den << @@UNIT_VALUES[unit][:denominator] if @@UNIT_VALUES[unit] && @@UNIT_VALUES[unit][:denominator]
      end
    end
    for unit in @denominator.compact do
      if @@PREFIX_VALUES[unit]
        if q.kind_of?(Fixnum)
          q = q.quo(@@PREFIX_VALUES[unit])
        else
          q /= @@PREFIX_VALUES[unit]
        end
      else
        if @@UNIT_VALUES[unit]
          if q.kind_of?(Fixnum)
            q = q.quo(@@UNIT_VALUES[unit][:scalar])
          else
            q /= @@UNIT_VALUES[unit][:scalar]
          end
        end
        den << @@UNIT_VALUES[unit][:numerator] if @@UNIT_VALUES[unit] && @@UNIT_VALUES[unit][:numerator]
        num << @@UNIT_VALUES[unit][:denominator] if @@UNIT_VALUES[unit] && @@UNIT_VALUES[unit][:denominator]
      end
    end

    num = num.flatten.compact
    den = den.flatten.compact
    num = UNITY_ARRAY if num.empty?
    base= Unit.new(Unit.eliminate_terms(q,num,den))
    @@base_unit_cache[self.units]=base
    return base * @scalar
  end
  alias :base :to_base

  # Generate human readable output.
  # If the name of a unit is passed, the unit will first be converted to the target unit before output.
  # some named conversions are available
  #
  # @example
  #  unit.to_s(:ft) - outputs in feet and inches (e.g., 6'4")
  #  unit.to_s(:lbs) - outputs in pounds and ounces (e.g, 8 lbs, 8 oz)
  #
  # You can also pass a standard format string (i.e., '%0.2f')
  # or a strftime format string.
  #
  # output is cached so subsequent calls for the same format will be fast
  #
  # @param [Symbol] target_units
  # @return [String]
  def to_s(target_units=nil)
    out = @output[target_units]
    if out
      return out
    else
      case target_units
      when :ft
        inches = self.convert_to("in").scalar.to_int
        out = "#{(inches / 12).truncate}\'#{(inches % 12).round}\""
      when :lbs
        ounces = self.convert_to("oz").scalar.to_int
        out = "#{(ounces / 16).truncate} lbs, #{(ounces % 16).round} oz"
      when String
        out = case target_units
        when /(%[\-+\.\w#]+)\s*(.+)*/       #format string like '%0.2f in'
          begin
            if $2 #unit specified, need to convert
              self.convert_to($2).to_s($1)
            else
              "#{$1 % @scalar} #{$2 || self.units}".strip
            end
          rescue # parse it like a strftime format string
            (DateTime.new(0) + self).strftime(target_units)
          end
        when /(\S+)/ #unit only 'mm' or '1/mm'
          self.convert_to($1).to_s
        else
          raise "unhandled case"
        end
      else
        out = case @scalar
        when Rational
          "#{@scalar} #{self.units}"
        else
          "#{'%g' % @scalar} #{self.units}"
        end.strip
      end
      @output[target_units] = out
      return out
    end
  end

  # Normally pretty prints the unit, but if you really want to see the guts of it, pass ':dump'
  # @deprecated
  # @return [String]
  def inspect(option=nil)
    return super() if option == :dump
    return self.to_s
  end

  # true if unit is a 'temperature', false if a 'degree' or anything else
  # @return [Boolean]
  # @todo use unit definition to determine if it's a temperature instead of a regex
  def is_temperature?
    return self.is_degree? && (!(@@UNIT_MAP[self.units] =~ /temp[CFRK]/).nil?)
  end
  alias :temperature? :is_temperature?

  # true if a degree unit or equivalent.
  # @return [Boolean]
  def is_degree?
    return self.kind == :temperature
  end
  alias :degree? :is_degree?

  # returns the 'degree' unit associated with a temperature unit
  # @example '100 tempC'.unit.temperature_scale #=> 'degC'
  # @return [String] possible values: degC, degF, degR, or degK
  def temperature_scale
    return nil unless self.is_temperature?
    return "deg#{@@UNIT_MAP[self.units][/temp([CFRK])/,1]}"
  end

  # returns true if no associated units
  # false, even if the units are "unitless" like 'radians, each, etc'
  # @return [Boolean]
  def unitless?
    return(@numerator == UNITY_ARRAY && @denominator == UNITY_ARRAY)
  end

  # Compare two Unit objects. Throws an exception if they are not of compatible types.
  # Comparisons are done based on the value of the unit in base SI units.
  # @param [Object] other
  # @return [-1|0|1|nil]
  # @raise [NoMethodError] when other does not define <=>
  # @raise [ArgumentError] when units are not compatible
  def <=>(other)
    case
    when !self.base_scalar.respond_to?(:<=>)
      raise NoMethodError, "undefined method `<=>' for #{self.base_scalar.inspect}"
    when other.nil?
      return self.base_scalar <=> nil
    when !self.is_temperature? && other.zero?
      return self.base_scalar <=> 0
    when other.instance_of?(Unit)
      raise ArgumentError, "Incompatible Units (#{self.units} !~ #{other.units})" unless self =~ other
      return self.base_scalar <=> other.base_scalar
    else
      x,y = coerce(other)
      return x <=> y
    end
  end

  # Compare Units for equality
  # this is necessary mostly for Complex units.  Complex units do not have a <=> operator
  # so we define this one here so that we can properly check complex units for equality.
  # Units of incompatible types are not equal, except when they are both zero and neither is a temperature
  # Equality checks can be tricky since round off errors may make essentially equivalent units
  # appear to be different.
  # @param [Object] other
  # @return [Boolean]
  def ==(other)
    case
    when other.respond_to?(:zero?) && other.zero?
      return self.zero?
    when other.instance_of?(Unit)
      return false unless self =~ other
      return self.base_scalar == other.base_scalar
    else
      begin
        x,y = coerce(other)
        return x == y
      rescue ArgumentError # return false when object cannot be coerced
        return false
      end
    end
  end

  # check to see if units are compatible, but not the scalar part
  # this check is done by comparing signatures for performance reasons
  # if passed a string, it will create a unit object with the string and then do the comparison
  # @example this permits a syntax like:
  #  unit =~ "mm"
  # @note if you want to do a regexp comparison of the unit string do this ...
  #  unit.units =~ /regexp/
  # @param [Object] other
  # @return [Boolean]
  def =~(other)
    case other
    when Unit
      self.signature == other.signature
    else
      begin
        x,y = coerce(other)
        return x =~ y
      rescue ArgumentError
        return false
      end
    end
  end

  alias :compatible? :=~
  alias :compatible_with? :=~

  # Compare two units.  Returns true if quantities and units match
  # @example
  #   Unit("100 cm") === Unit("100 cm")   # => true
  #   Unit("100 cm") === Unit("1 m")      # => false
  # @param [Object] other
  # @return [Boolean]
  def ===(other)
    case other
    when Unit
      (self.scalar == other.scalar) && (self.units == other.units)
    else
      begin
        x,y = coerce(other)
        return x === y
      rescue ArgumentError
        return false
      end
    end
  end

  alias :same? :===
  alias :same_as? :===

  # Add two units together.  Result is same units as receiver and scalar and base_scalar are updated appropriately
  # throws an exception if the units are not compatible.
  # It is possible to add Time objects to units of time
  # @param [Object] other
  # @return [Unit]
  # @raise [ArgumentError] when two temperatures are added
  # @raise [ArgumentError] when units are not compatible
  # @raise [ArgumentError] when adding a fixed time or date to a time span
  def +(other)
    case other
    when Unit
      case
      when self.zero?
        other.dup
      when self =~ other
        raise ArgumentError, "Cannot add two temperatures" if ([self, other].all? {|x| x.is_temperature?})
        if [self, other].any? {|x| x.is_temperature?}
          if self.is_temperature?
            Unit.new(:scalar => (self.scalar + other.convert_to(self.temperature_scale).scalar), :numerator => @numerator, :denominator=>@denominator, :signature => @signature)
          else
            Unit.new(:scalar => (other.scalar + self.convert_to(other.temperature_scale).scalar), :numerator => other.numerator, :denominator=>other.denominator, :signature => other.signature)
          end
        else
          if @@cached_units[self.units].scalar.kind_of?(Fixnum)
            @q ||= ((@@cached_units[self.units].scalar.quo(@@cached_units[self.units].base_scalar)) rescue (self.units.unit.to_base.scalar))
          else
            @q ||= ((@@cached_units[self.units].scalar / @@cached_units[self.units].base_scalar) rescue (self.units.unit.to_base.scalar))
          end
          Unit.new(:scalar=>(self.base_scalar + other.base_scalar)*@q, :numerator=>@numerator, :denominator=>@denominator, :signature => @signature)
        end
      else
        raise ArgumentError,  "Incompatible Units ('#{self}' not compatible with '#{other}')"
      end
    when Date, Time
      raise ArgumentError, "Date and Time objects represent fixed points in time and cannot be added to a Unit"
    else
      x,y = coerce(other)
      y + x
    end
  end

  # Subtract two units. Result is same units as receiver and scalar and base_scalar are updated appropriately
  # @param [Numeric] other
  # @return [Unit]
  # @raise [ArgumentError] when subtracting a temperature from a degree
  # @raise [ArgumentError] when units are not compatible
  # @raise [ArgumentError] when subtracting a fixed time from a time span
  def -(other)
    case other
      when Unit
        case
        when self.zero?
          if other.zero?
            other.dup * -1 # preserve Units class
          else
            -other.dup
          end
        when self =~ other
          case
            when [self, other].all? {|x| x.is_temperature?}
              Unit.new(:scalar => (self.base_scalar - other.base_scalar), :numerator  => KELVIN, :denominator => UNITY_ARRAY, :signature => @signature).convert_to(self.temperature_scale)
            when self.is_temperature?
              Unit.new(:scalar => (self.base_scalar - other.base_scalar), :numerator  => ['<tempK>'], :denominator => UNITY_ARRAY, :signature => @signature).convert_to(self)
            when other.is_temperature?
              raise ArgumentError, "Cannot subtract a temperature from a differential degree unit"
            else
              if @@cached_units[self.units].scalar.kind_of?(Fixnum)
                @q ||= ((@@cached_units[self.units].scalar.quo(@@cached_units[self.units].base_scalar)) rescue (self.units.unit.scalar.quo(self.units.unit.to_base.scalar)))
              else
                @q ||= ((@@cached_units[self.units].scalar / @@cached_units[self.units].base_scalar) rescue (self.units.unit.scalar/self.units.unit.to_base.scalar))
              end
              Unit.new(:scalar=>(self.base_scalar - other.base_scalar)*@q, :numerator=>@numerator, :denominator=>@denominator, :signature=>@signature)
          end
        else
           raise ArgumentError,  "Incompatible Units ('#{self}' not compatible with '#{other}')"
        end
    when Time
      raise ArgumentError, "Date and Time objects represent fixed points in time and cannot be subtracted from to a Unit, which can only represent time spans"
    else
        x,y = coerce(other)
        return y-x
    end
  end

  # Multiply two units.
  # @param [Numeric] other
  # @return [Unit]
  # @raise [ArgumentError] when attempting to multiply two temperatures
  def *(other)
    case other
    when Unit
      raise ArgumentError, "Cannot multiply by temperatures" if [other,self].any? {|x| x.is_temperature?}
      opts = Unit.eliminate_terms(@scalar*other.scalar, @numerator + other.numerator ,@denominator + other.denominator)
      opts.merge!(:signature => @signature + other.signature)
      return Unit.new(opts)
    when Numeric
      return Unit.new(:scalar=>@scalar*other, :numerator=>@numerator, :denominator=>@denominator, :signature => @signature)
    else
      x,y = coerce(other)
      return x * y
    end
  end

  # Divide two units.
  # Throws an exception if divisor is 0
  # @param [Numeric] other
  # @return [Unit]
  # @raise [ZeroDivisionError] if divisor is zero
  # @raise [ArgumentError] if attempting to divide a temperature by another temperature
  def /(other)
    case other
    when Unit
      raise ZeroDivisionError if other.zero?
      raise ArgumentError, "Cannot divide with temperatures" if [other,self].any? {|x| x.is_temperature?}
      opts = if @scalar.kind_of?(Fixnum)
        Unit.eliminate_terms(@scalar.quo(other.scalar), @numerator + other.denominator ,@denominator + other.numerator)
      else
        Unit.eliminate_terms(@scalar/other.scalar, @numerator + other.denominator ,@denominator + other.numerator)
      end
      opts.merge!(:signature=> @signature - other.signature)
      return Unit.new(opts)
    when Numeric
      raise ZeroDivisionError if other.zero?
      if @scalar.kind_of?(Fixnum)
        return Unit.new(:scalar=>@scalar.quo(other), :numerator=>@numerator, :denominator=>@denominator, :signature => @signature)
      else
        return Unit.new(:scalar=>@scalar/other, :numerator=>@numerator, :denominator=>@denominator, :signature => @signature)
      end
    else
      x,y = coerce(other)
      return y / x
    end
  end

  # divide two units and return quotient and remainder
  # when both units are in the same units we just use divmod on the raw scalars
  # otherwise we use the scalar of the base unit which will be a float
  # @param [Object] other
  # @return [Array]
  def divmod(other)
    raise ArgumentError, "Incompatible Units" unless self =~ other
    if self.units == other.units
      return self.scalar.divmod(other.scalar)
    else
      return self.to_base.scalar.divmod(other.to_base.scalar)
    end
  end

  # perform a modulo on a unit, will raise an exception if the units are not compatible
  # @param [Object] other
  # @return [Integer]
  def %(other)
    return self.divmod(other).last
  end

  # Exponentiate.  Only takes integer powers.
  # Note that anything raised to the power of 0 results in a Unit object with a scalar of 1, and no units.
  # Throws an exception if exponent is not an integer.
  # Ideally this routine should accept a float for the exponent
  # It should then convert the float to a rational and raise the unit by the numerator and root it by the denominator
  # but, sadly, floats can't be converted to rationals.
  #
  # For now, if a rational is passed in, it will be used, otherwise we are stuck with integers and certain floats < 1
  # @param [Numeric] other
  # @return [Unit]
  # @raise [ArgumentError] when raising a temperature to a power
  # @raise [ArgumentError] when n not in the set integers from (1..9)
  # @raise [ArgumentError] when attempting to raise to a complex number
  # @raise [ArgumentError] when an invalid exponent is passed
  def **(other)
    raise ArgumentError, "Cannot raise a temperature to a power" if self.is_temperature?
    if other.kind_of?(Numeric)
      return self.inverse if other == -1
      return self if other == 1
      return 1 if other.zero?
    end
    case other
    when Rational
      return self.power(other.numerator).root(other.denominator)
    when Integer
      return self.power(other)
    when Float
      return self**(other.to_i) if other == other.to_i
      valid = (1..9).map {|x| 1.quo(x)}
      raise ArgumentError, "Not a n-th root (1..9), use 1/n" unless valid.include? other.abs
      return self.root((1.quo(other)).to_int)
    when (!defined?(Complex).nil? && Complex)
      raise ArgumentError, "exponentiation of complex numbers is not yet supported."
    else
      raise ArgumentError, "Invalid Exponent"
    end
  end

  # returns the unit raised to the n-th power
  # @param [Integer] n
  # @return [Unit]
  # @raise [ArgumentError] when attempting to raise a temperature to a power
  # @raise [ArgumentError] when n is not an integer
  def power(n)
    raise ArgumentError, "Cannot raise a temperature to a power" if self.is_temperature?
    raise ArgumentError, "Exponent must an Integer" unless n.kind_of?(Integer)
    return self.inverse if n == -1
    return 1 if n.zero?
    return self if n == 1
    if n > 0 then
      return (1..(n-1).to_i).inject(self) {|product, x| product * self}
    else
      return (1..-(n-1).to_i).inject(self) {|product, x| product / self}
    end
  end

  # Calculates the n-th root of a unit
  # if n < 0, returns 1/unit^(1/n)
  # @param [Integer] n
  # @return [Unit]
  # @raise [ArgumentError] when attemptint to take the root of a temperature
  # @raise [ArgumentError] when n is not an integer
  # @raise [ArgumentError] when n is 0
  def root(n)
    raise ArgumentError, "Cannot take the root of a temperature" if self.is_temperature?
    raise ArgumentError, "Exponent must an Integer" unless n.kind_of?(Integer)
    raise ArgumentError, "0th root undefined" if n.zero?
    return self if n == 1
    return self.root(n.abs).inverse if n < 0

    vec = self.unit_signature_vector
    vec=vec.map {|x| x % n}
    raise ArgumentError, "Illegal root" unless vec.max == 0
    num = @numerator.dup
    den = @denominator.dup

    for item in @numerator.uniq do
      x = num.find_all {|i| i==item}.size
      r = ((x/n)*(n-1)).to_int
      r.times {|y| num.delete_at(num.index(item))}
    end

    for item in @denominator.uniq do
      x = den.find_all {|i| i==item}.size
      r = ((x/n)*(n-1)).to_int
      r.times {|y| den.delete_at(den.index(item))}
    end
    q = @scalar < 0 ? (-1)**Rational(1,n) * (@scalar.abs)**Rational(1,n) : @scalar**Rational(1,n)
    return Unit.new(:scalar=>q,:numerator=>num,:denominator=>den)
  end

  # returns inverse of Unit (1/unit)
  # @return [Unit]
  def inverse
    return Unit("1") / self
  end

  # convert to a specified unit string or to the same units as another Unit
  #
  #  unit.convert_to "kg"   will covert to kilograms
  #  unit1.convert_to unit2 converts to same units as unit2 object
  #
  # To convert a Unit object to match another Unit object, use:
  #  unit1 >>= unit2
  #
  # Special handling for temperature conversions is supported.  If the Unit object is converted
  # from one temperature unit to another, the proper temperature offsets will be used.
  # Supports Kelvin, Celsius, Fahrenheit, and Rankine scales.
  #
  # @note If temperature is part of a compound unit, the temperature will be treated as a differential
  #   and the units will be scaled appropriately.
  # @param [Object] other
  # @return [Unit]
  # @raise [ArgumentError] when attempting to convert a degree to a temperature
  # @raise [ArgumentError] when target unit is unknown
  # @raise [ArgumentError] when target unit is incompatible
  def convert_to(other)
    return self if other.nil?
    return self if TrueClass === other
    return self if FalseClass === other
    if (Unit === other && other.is_temperature?) || (String === other && other =~ /temp[CFRK]/)
      raise ArgumentError, "Receiver is not a temperature unit" unless self.degree?
      start_unit = self.units
      target_unit = other.units rescue other
      unless @base_scalar
        @base_scalar = case @@UNIT_MAP[start_unit]
        when '<tempC>'
          @scalar + 273.15
        when '<tempK>'
          @scalar
        when '<tempF>'
          (@scalar+459.67)*Rational(5,9)
        when '<tempR>'
          @scalar*Rational(5,9)
        end
      end
      q=  case @@UNIT_MAP[target_unit]
      when '<tempC>'
        @base_scalar - 273.15
      when '<tempK>'
        @base_scalar
      when '<tempF>'
        @base_scalar * Rational(9,5) - 459.67
      when '<tempR>'
        @base_scalar * Rational(9,5)
      end
      return Unit.new("#{q} #{target_unit}")
    else
      case other
      when Unit
        return self if other.units == self.units
        target = other
      when String
        target = Unit.new(other)
      else
        raise ArgumentError, "Unknown target units"
      end
      raise ArgumentError,  "Incompatible Units (#{self.units} !~ #{target.units})" unless self =~ target
      _numerator1 = @numerator.map {|x| @@PREFIX_VALUES[x] ? @@PREFIX_VALUES[x] : x}.map {|i| i.kind_of?(Numeric) ? i : @@UNIT_VALUES[i][:scalar] }.compact
      _denominator1 = @denominator.map {|x| @@PREFIX_VALUES[x] ? @@PREFIX_VALUES[x] : x}.map {|i| i.kind_of?(Numeric) ? i : @@UNIT_VALUES[i][:scalar] }.compact
      _numerator2 = target.numerator.map {|x| @@PREFIX_VALUES[x] ? @@PREFIX_VALUES[x] : x}.map {|x| x.kind_of?(Numeric) ? x : @@UNIT_VALUES[x][:scalar] }.compact
      _denominator2 = target.denominator.map {|x| @@PREFIX_VALUES[x] ? @@PREFIX_VALUES[x] : x}.map {|x| x.kind_of?(Numeric) ? x : @@UNIT_VALUES[x][:scalar] }.compact

      q = @scalar * ( (_numerator1 + _denominator2).inject(1) {|product,n| product*n} ) /
          ( (_numerator2 + _denominator1).inject(1) {|product,n| product*n} )
      return Unit.new(:scalar=>q, :numerator=>target.numerator, :denominator=>target.denominator, :signature => target.signature)
    end
  end
  alias :>> :convert_to
  alias :to :convert_to

  # converts the unit back to a float if it is unitless.  Otherwise raises an exception
  # @return [Float]
  # @raise [RuntimeError] when not unitless
  def to_f
    return @scalar.to_f if self.unitless?
    raise RuntimeError, "Cannot convert '#{self.to_s}' to Float unless unitless.  Use Unit#scalar"
  end

  # converts the unit back to a complex if it is unitless.  Otherwise raises an exception
  # @return [Complex]
  # @raise [RuntimeError] when not unitless
  def to_c
    return Complex(@scalar) if self.unitless?
    raise RuntimeError, "Cannot convert '#{self.to_s}' to Complex unless unitless.  Use Unit#scalar"
  end

  # if unitless, returns an int, otherwise raises an error
  # @return [Integer]
  # @raise [RuntimeError] when not unitless
  def to_i
    return @scalar.to_int if self.unitless?
    raise RuntimeError, "Cannot convert '#{self.to_s}' to Integer unless unitless.  Use Unit#scalar"
  end
  alias :to_int :to_i

  # if unitless, returns a Rational, otherwise raises an error
  # @return [Rational]
  # @raise [RuntimeError] when not unitless
  def to_r
    return @scalar.to_r if self.unitless?
    raise RuntimeError, "Cannot convert '#{self.to_s}' to Rational unless unitless.  Use Unit#scalar"
  end

  # Returns string formatted for json
  # @return [String]
  def as_json(*args)
    to_s
  end

  # returns the 'unit' part of the Unit object without the scalar
  # @return [String]
  def units
    return "" if @numerator == UNITY_ARRAY && @denominator == UNITY_ARRAY
    return @unit_name unless @unit_name.nil?
    output_numerator   = []
    output_denominator = []
    num                = @numerator.clone.compact
    den                = @denominator.clone.compact

    if @numerator == UNITY_ARRAY
      output_numerator << "1"
    else
      while defn = Unit.definition(num.shift) do
        if defn && defn.prefix?
          output_numerator << defn.display_name + Unit.definition(num.shift).display_name
        else
          output_numerator << defn.display_name
        end
      end
    end

    if @denominator == UNITY_ARRAY
      output_denominator = []
    else
      while defn = Unit.definition(den.shift) do
        if defn && defn.prefix?
          output_denominator << defn.display_name + Unit.definition(den.shift).display_name
        else
          output_denominator << defn.display_name
        end
      end
    end

    on = output_numerator.uniq.
          map {|x| [x, output_numerator.count(x)]}.
          map {|element, power| ("#{element}".strip + (power > 1 ? "^#{power}" : ''))}
    od = output_denominator.uniq.
          map {|x| [x, output_denominator.count(x)]}.
          map {|element, power| ("#{element}".strip + (power > 1 ? "^#{power}" : ''))}
    out = "#{on.join('*')}#{od.empty? ? '': '/' + od.join('*')}".strip
    @unit_name = out unless self.kind == :temperature
    return out
  end

  # negates the scalar of the Unit
  # @return [Numeric,Unit]
  def -@
    return -@scalar if self.unitless?
    return (self.dup * -1)
  end

  # absolute value of a unit
  # @return [Numeric,Unit]
  def abs
    return @scalar.abs if self.unitless?
    return Unit.new(@scalar.abs, @numerator, @denominator)
  end

  # ceil of a unit
  # @return [Numeric,Unit]
  def ceil
    return @scalar.ceil if self.unitless?
    return Unit.new(@scalar.ceil, @numerator, @denominator)
  end

  # @return [Numeric,Unit]
  def floor
    return @scalar.floor if self.unitless?
    return Unit.new(@scalar.floor, @numerator, @denominator)
  end

  if RUBY_VERSION < '1.9'
    # @return [Numeric,Unit]
    def round
      return @scalar.round if self.unitless?
      return Unit.new(@scalar.round, @numerator, @denominator)
    end
  else
    # @return [Numeric,Unit]
    def round(ndigits = 0)
      return @scalar.round(ndigits) if self.unitless?
      return Unit.new(@scalar.round(ndigits), @numerator, @denominator)
    end
  end

  # @return [Numeric, Unit]
  def truncate
    return @scalar.truncate if self.unitless?
    return Unit.new(@scalar.truncate, @numerator, @denominator)
  end

  # returns next unit in a range.  '1 mm'.unit.succ #=> '2 mm'.unit
  # only works when the scalar is an integer
  # @return [Unit]
  # @raise [ArgumentError] when scalar is not equal to an integer
  def succ
    raise ArgumentError, "Non Integer Scalar" unless @scalar == @scalar.to_i
    return Unit.new(@scalar.to_i.succ, @numerator, @denominator)
  end
  alias :next :succ

  # returns previous unit in a range.  '2 mm'.unit.pred #=> '1 mm'.unit
  # only works when the scalar is an integer
  # @return [Unit]
  # @raise [ArgumentError] when scalar is not equal to an integer
  def pred
    raise ArgumentError, "Non Integer Scalar" unless @scalar == @scalar.to_i
    return Unit.new(@scalar.to_i.pred, @numerator, @denominator)
  end

  # Tries to make a Time object from current unit.  Assumes the current unit hold the duration in seconds from the epoch.
  # @return [Time]
  def to_time
    return Time.at(self)
  end
  alias :time :to_time

  # convert a duration to a DateTime.  This will work so long as the duration is the duration from the zero date
  # defined by DateTime
  # @return [DateTime]
  def to_datetime
    return DateTime.new!(self.convert_to('d').scalar)
  end

  # @return [Date]
  def to_date
    return Date.new0(self.convert_to('d').scalar)
  end

  # true if scalar is zero
  # @return [Boolean]
  def zero?
    return self.base_scalar.zero?
  end

  # @example '5 min'.unit.ago
  # @return [Unit]
  def ago
    return self.before
  end

  # @example '5 min'.before(time)
  # @return [Unit]
  def before(time_point = ::Time.now)
    case time_point
    when Time, Date, DateTime
      return (time_point - self rescue time_point.to_datetime - self)
    else
      raise ArgumentError, "Must specify a Time, Date, or DateTime"
    end
  end
  alias :before_now :before

  # @example 'min'.since(time)
  # @param [Time, Date, DateTime] time_point
  # @return [Unit]
  # @raise [ArgumentError] when time point is not a Time, Date, or DateTime
  def since(time_point)
    case time_point
    when Time
      return (Time.now - time_point).unit('s').convert_to(self)
    when DateTime, Date
      return (DateTime.now - time_point).unit('d').convert_to(self)
    else
      raise ArgumentError, "Must specify a Time, Date, or DateTime"
    end
  end

  # @example 'min'.until(time)
  # @param [Time, Date, DateTime] time_point
  # @return [Unit]
  def until(time_point)
    case time_point
    when Time
      return (time_point - Time.now).unit('s').convert_to(self)
    when DateTime, Date
      return (time_point - DateTime.now).unit('d').convert_to(self)
    else
      raise ArgumentError, "Must specify a Time, Date, or DateTime"
    end
  end

  # @example '5 min'.from(time)
  # @param [Time, Date, DateTime] time_point
  # @return [Time, Date, DateTime]
  # @raise [ArgumentError] when passed argument is not a Time, Date, or DateTime
  def from(time_point)
    case time_point
    when Time, DateTime, Date
      return (time_point + self rescue time_point.to_datetime + self)
    else
      raise ArgumentError, "Must specify a Time, Date, or DateTime"
    end
  end
  alias :after :from
  alias :from_now :from

  # automatically coerce objects to units when possible
  # if an object defines a 'to_unit' method, it will be coerced using that method
  # @param [Object, #to_unit]
  # @return [Array]
  def coerce(other)
    if other.respond_to? :to_unit
      return [other.to_unit, self]
    end
    case other
    when Unit
      return [other, self]
    else
      return [Unit.new(other), self]
    end
  end

  # Protected and Private Functions that should only be called from this class
  protected

  # figure out what the scalar part of the base unit for this unit is
  # @return [nil]
  def update_base_scalar
    if self.is_base?
      @base_scalar = @scalar
      @signature = unit_signature
    else
      base = self.to_base
      @base_scalar = base.scalar
      @signature = base.signature
    end
  end

  # calculates the unit signature vector used by unit_signature
  # @return [Array]
  # @raise [ArgumentError] when exponent associated with a unit is > 20 or < -20
  def unit_signature_vector
    return self.to_base.unit_signature_vector unless self.is_base?
    vector = Array.new(SIGNATURE_VECTOR.size,0)
    # it's possible to have a kind that misses the array... kinds like :counting
    # are more like prefixes, so don't use them to calculate the vector
    @numerator.map {|element| Unit.definition(element)}.each do |definition|
      index = SIGNATURE_VECTOR.index(definition.kind)
      vector[index] += 1 if index
    end
    @denominator.map {|element| Unit.definition(element)}.each do |definition|
      index = SIGNATURE_VECTOR.index(definition.kind)
      vector[index] -= 1 if index
    end
    raise ArgumentError, "Power out of range (-20 < net power of a unit < 20)" if vector.any? {|x| x.abs >=20}
    return vector
  end

  private

  # used by #dup to duplicate a Unit
  # @param [Unit] other
  # @private
  def initialize_copy(other)
    @numerator = other.numerator.dup
    @denominator = other.denominator.dup
  end

  # calculates the unit signature id for use in comparing compatible units and simplification
  # the signature is based on a simple classification of units and is based on the following publication
  #
  # Novak, G.S., Jr. "Conversion of units of measurement", IEEE Transactions on Software Engineering, 21(8), Aug 1995, pp.651-661
  # @see http://doi.ieeecomputersociety.org/10.1109/32.403789
  # @return [Array]
  def unit_signature
    return @signature unless @signature.nil?
    vector = unit_signature_vector
    vector.each_with_index {|item,index| vector[index] = item * 20**index}
    @signature=vector.inject(0) {|sum,n| sum+n}
    return @signature
  end

  # @param [Numeric] q quantity
  # @param [Array] n numerator
  # @param [Array] d denominator
  # @return [Hash]
  def self.eliminate_terms(q, n, d)
    num = n.dup
    den = d.dup

    num.delete_if {|v| v == UNITY}
    den.delete_if {|v| v == UNITY}
    combined = Hash.new(0)

    i = 0
    loop do
      break if i > num.size
      if @@PREFIX_VALUES.has_key? num[i]
        k = [num[i],num[i+1]]
        i += 2
      else
        k = num[i]
        i += 1
      end
      combined[k] += 1 unless k.nil? || k == UNITY
    end

    j = 0
    loop do
      break if j > den.size
        if @@PREFIX_VALUES.has_key? den[j]
          k = [den[j],den[j+1]]
          j += 2
        else
          k = den[j]
          j += 1
        end
      combined[k] -= 1 unless k.nil? || k == UNITY
    end

    num = []
    den = []
    for key, value in combined do
      case
      when value > 0
        value.times {num << key}
      when value < 0
        value.abs.times {den << key}
      end
    end
    num = UNITY_ARRAY if num.empty?
    den = UNITY_ARRAY if den.empty?
    return {:scalar=>q, :numerator=>num.flatten.compact, :denominator=>den.flatten.compact}
  end

  # parse a string into a unit object.
  # Typical formats like :
  #  "5.6 kg*m/s^2"
  #  "5.6 kg*m*s^-2"
  #  "5.6 kilogram*meter*second^-2"
  #  "2.2 kPa"
  #  "37 degC"
  #  "1"  -- creates a unitless constant with value 1
  #  "GPa"  -- creates a unit with scalar 1 with units 'GPa'
  #  6'4"  -- recognized as 6 feet + 4 inches
  #  8 lbs 8 oz -- recognized as 8 lbs + 8 ounces
  # @return [nil | Unit]
  # @todo This should either be a separate class or at least a class method
  def parse(passed_unit_string="0")
    unit_string = passed_unit_string.dup
    if unit_string =~ /\$\s*(#{NUMBER_REGEX})/
      unit_string = "#{$1} USD"
    end
    unit_string.gsub!("\u00b0".force_encoding('utf-8'), 'deg') if RUBY_VERSION >= '1.9' && unit_string.encoding == Encoding::UTF_8

    unit_string.gsub!(/%/,'percent')
    unit_string.gsub!(/'/,'feet')
    unit_string.gsub!(/"/,'inch')
    unit_string.gsub!(/#/,'pound')

    #:nocov:
    #:nocov_19:
    if defined?(Uncertain) && unit_string =~ /(\+\/-|&plusmn;)/
      value, uncertainty, unit_s = unit_string.scan(UNCERTAIN_REGEX)[0]
      result = unit_s.unit * Uncertain.new(value.to_f,uncertainty.to_f)
      copy(result)
      return
    end
    #:nocov:
    #:nocov_19:

    if defined?(Complex) && unit_string =~ COMPLEX_NUMBER
      real, imaginary, unit_s = unit_string.scan(COMPLEX_REGEX)[0]
      result = Unit(unit_s || '1') * Complex(real.to_f,imaginary.to_f)
      copy(result)
      return
    end

    power_match = /\^\d+\/\d+/ # This prevents thinking e.g. kg^2/100kg*ha is rational because of 2 / 100
    if defined?(Rational) && unit_string =~ RATIONAL_NUMBER && ! unit_string.match(power_match)
      numerator, denominator, unit_s = unit_string.scan(RATIONAL_REGEX)[0]
      result = Unit(unit_s || '1') * Rational(numerator.to_i,denominator.to_i)
      copy(result)
      return
    end

    unit_string =~ NUMBER_REGEX
    unit = @@cached_units[$2]
    mult = ($1.empty? ? 1.0 : $1.to_f) rescue 1.0
    mult = mult.to_int if (mult.to_int == mult)
    if unit
      copy(unit)
      @scalar *= mult
      @base_scalar *= mult
      return self
    end
    unit_string.gsub!(/<(#{@@UNIT_REGEX})><(#{@@UNIT_REGEX})>/, '\1*\2')
    unit_string.gsub!(/[<>]/,"")

    if unit_string =~ /:/
      hours, minutes, seconds, microseconds = unit_string.scan(TIME_REGEX)[0]
      raise ArgumentError, "Invalid Duration" if [hours, minutes, seconds, microseconds].all? {|x| x.nil?}
      result = "#{hours || 0} h".unit +
               "#{minutes || 0} minutes".unit +
               "#{seconds || 0} seconds".unit +
               "#{microseconds || 0} usec".unit
      copy(result)
      return
    end

    # Special processing for unusual unit strings
    # feet -- 6'5"
    feet, inches = unit_string.scan(FEET_INCH_REGEX)[0]
    if (feet && inches)
      result = Unit.new("#{feet} ft") + Unit.new("#{inches} inches")
      copy(result)
      return
    end

    # weight -- 8 lbs 12 oz
    pounds, oz = unit_string.scan(LBS_OZ_REGEX)[0]
    if (pounds && oz)
      result = Unit.new("#{pounds} lbs") + Unit.new("#{oz} oz")
      copy(result)
      return
    end

    # more than one per.  I.e., "1 m/s/s"
    raise( ArgumentError, "'#{passed_unit_string}' Unit not recognized") if unit_string.count('/') > 1
    raise( ArgumentError, "'#{passed_unit_string}' Unit not recognized") if unit_string.scan(/\s[02-9]/).size > 0
    @scalar, top, bottom = unit_string.scan(UNIT_STRING_REGEX)[0]  #parse the string into parts
    top.scan(TOP_REGEX).each do |item|
      n = item[1].to_i
      x = "#{item[0]} "
      case
        when n>=0
          top.gsub!(/#{item[0]}(\^|\*\*)#{n}/) {|s| x * n}
        when n<0
          bottom = "#{bottom} #{x * -n}"; top.gsub!(/#{item[0]}(\^|\*\*)#{n}/,"")
      end
    end
    bottom.gsub!(BOTTOM_REGEX) {|s| "#{$1} " * $2.to_i} if bottom
    @scalar = @scalar.to_f unless @scalar.nil? || @scalar.empty?
    @scalar = 1 unless @scalar.kind_of? Numeric
    @scalar = @scalar.to_int if (@scalar.to_int == @scalar)

    @numerator ||= UNITY_ARRAY
    @denominator ||= UNITY_ARRAY
    @numerator = top.scan(Unit.unit_match_regex).delete_if {|x| x.empty?}.compact if top
    @denominator = bottom.scan(Unit.unit_match_regex).delete_if {|x| x.empty?}.compact if bottom

    # eliminate all known terms from this string.  This is a quick check to see if the passed unit
    # contains terms that are not defined.
    used = "#{top} #{bottom}".to_s.gsub(Unit.unit_match_regex,'').gsub(/[\d\*, "'_^\/\$]/,'')
    raise( ArgumentError, "'#{passed_unit_string}' Unit not recognized") unless used.empty?

    @numerator = @numerator.map do |item|
       @@PREFIX_MAP[item[0]] ? [@@PREFIX_MAP[item[0]], @@UNIT_MAP[item[1]]] : [@@UNIT_MAP[item[1]]]
    end.flatten.compact.delete_if {|x| x.empty?}

    @denominator = @denominator.map do |item|
       @@PREFIX_MAP[item[0]] ? [@@PREFIX_MAP[item[0]], @@UNIT_MAP[item[1]]] : [@@UNIT_MAP[item[1]]]
    end.flatten.compact.delete_if {|x| x.empty?}

    @numerator = UNITY_ARRAY if @numerator.empty?
    @denominator = UNITY_ARRAY if @denominator.empty?
    return self
  end

  # return an array of base units
  # @return [Array]
  def self.base_units
    return @@base_units ||= @@definitions.dup.delete_if {|_, defn| !defn.base?}.keys.map {|u| Unit.new(u)}
  end

  private

  # parse a string consisting of a number and a unit string
  # @param [String] string
  # @return [Array] consisting of [Numeric, "unit"]
  # @private
  def self.parse_into_numbers_and_units(string)
    # scientific notation.... 123.234E22, -123.456e-10
    sci       = %r{[+-]?\d*[.]?\d+(?:[Ee][+-]?)?\d*}
    # rational numbers.... -1/3, 1/5, 20/100
    rational  = %r{[+-]?\d+\/\d+}
    # complex numbers... -1.2+3i, +1.2-3.3i
    complex   = %r{#{sci}{2,2}i}
    anynumber = %r{(?:(#{complex}|#{rational}|#{sci})\b)?\s?([\D].*)?}
    num, unit = string.scan(anynumber).first

    return [case num
      when NilClass
        1
      when complex
        if num.respond_to?(:to_c)
          num.to_c
        else
          #:nocov_19:
          Complex(*num.scan(/(#{sci})(#{sci})i/).flatten.map {|n| n.to_i})
          #:nocov_19:
        end
      when rational
        Rational(*num.split("/").map {|x| x.to_i})
      else
        num.to_f
    end, unit.to_s.strip]
  end

  # return a fragment of a regex to be used for matching units or reconstruct it if hasn't been used yet.
  # Unit names are reverse sorted by length so the regexp matcher will prefer longer and more specific names
  # @return [String]
  # @private
  def self.unit_regex
    @@UNIT_REGEX ||= @@UNIT_MAP.keys.sort_by {|unit_name| [unit_name.length, unit_name]}.reverse.join('|')
  end

  # return a regex used to match units
  # @return [RegExp]
  # @private
  def self.unit_match_regex
    @@UNIT_MATCH_REGEX ||= /(#{Unit.prefix_regex})*?(#{Unit.unit_regex})\b/
  end

  # return a regexp fragment used to match prefixes
  # @return [String]
  # @private
  def self.prefix_regex
    return @@PREFIX_REGEX ||= @@PREFIX_MAP.keys.sort_by {|prefix| [prefix.length, prefix]}.reverse.join('|')
  end

  def self.temp_regex
    @@TEMP_REGEX ||= Regexp.new "(?:#{
      temp_units=%w(tempK tempC tempF tempR degK degC degF degR)
      aliases=temp_units.map{|unit| d=Unit.definition(unit); d && d.aliases}.flatten.compact
      regex_str= aliases.empty? ? '(?!x)x' : aliases.join('|')
      regex_str
    })"
  end

  # inject a definition into the internal array and set it up for use
  # @private
  def self.use_definition(definition)
    @@UNIT_MATCH_REGEX = nil #invalidate the unit match regex
    @@TEMP_REGEX = nil #invalidate the temp regex
    if definition.prefix?
      @@PREFIX_VALUES[definition.name] = definition.scalar
      definition.aliases.each {|_alias| @@PREFIX_MAP[_alias] = definition.name }
      @@PREFIX_REGEX = nil  #invalidate the prefix regex
    else
      @@UNIT_VALUES[definition.name]                = {}
      @@UNIT_VALUES[definition.name][:scalar]       = definition.scalar
      @@UNIT_VALUES[definition.name][:numerator]    = definition.numerator if definition.numerator
      @@UNIT_VALUES[definition.name][:denominator]  = definition.denominator if definition.denominator
      definition.aliases.each {|_alias| @@UNIT_MAP[_alias] = definition.name}
      @@UNIT_REGEX    = nil #invalidate the unit regex
    end
  end

end
