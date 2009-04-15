require 'mathn'
require 'rational'
require 'date'
require 'parsedate'

# = Ruby Units
#
# Copyright 2006 by Kevin C. Olbrich, Ph.D.
# 
# See http://rubyforge.org/ruby-units/
#
# http://www.sciwerks.org
#
# mailto://kevin.olbrich+ruby-units@gmail.com
#
# See README for detailed usage instructions and examples
#
# ==Unit Definition Format
#
#  '<name>'  => [%w{prefered_name synonyms}, conversion_to_base, :classification, %w{<base> <units> <in> <numerator>} , %w{<base> <units> <in> <denominator>} ],
#
# Prefixes (e.g., a :prefix classification) get special handling
# Note: The accuracy of unit conversions depends on the precision of the conversion factor.
# If you have more accurate estimates for particular conversion factors, please send them 
# to me and I will incorporate them into the next release.  It is also incumbent on the end-user
# to ensure that the accuracy of any conversions is sufficient for their intended application.
#
# While there are a large number of unit specified in the base package, 
# there are also a large number of units that are not included.
# This package covers nearly all SI, Imperial, and units commonly used
# in the United States. If your favorite units are not listed here, send me an email
#
# To add / override a unit definition, add a code block like this..
#
#  class Unit < Numeric
#   UNIT_DEFINITIONS = {
#    <name>'  => [%w{prefered_name synonyms}, conversion_to_base, :classification, %w{<base> <units> <in> <numerator>} , %w{<base> <units> <in> <denominator>} ]
#    }
#  end
#  Unit.setup
class Unit < Numeric
  # pre-generate hashes from unit definitions for performance.  
  VERSION = '1.1.3'
  @@USER_DEFINITIONS = {}
  @@PREFIX_VALUES = {}
  @@PREFIX_MAP = {}
  @@UNIT_MAP = {}
  @@UNIT_VALUES = {}
  @@OUTPUT_MAP = {}
  @@BASE_UNITS = ['<meter>','<kilogram>','<second>','<mole>', '<farad>', '<ampere>','<radian>','<kelvin>','<temp-K>','<byte>','<dollar>','<candela>','<each>','<steradian>','<decibel>']
  UNITY = '<1>'
  UNITY_ARRAY= [UNITY]
  FEET_INCH_REGEX = /(\d+)\s*(?:'|ft|feet)\s*(\d+)\s*(?:"|in|inches)/
  TIME_REGEX = /(\d+)*:(\d+)*:*(\d+)*[:,]*(\d+)*/
  LBS_OZ_REGEX = /(\d+)\s*(?:#|lbs|pounds|pound-mass)+[\s,]*(\d+)\s*(?:oz|ounces)/
  SCI_NUMBER = %r{([+-]?\d*[.]?\d+(?:[Ee][+-]?)?\d*)}
  RATIONAL_NUMBER = /(\d+)\/(\d+)/
  COMPLEX_NUMBER = /#{SCI_NUMBER}?#{SCI_NUMBER}i\b/
  NUMBER_REGEX = /#{SCI_NUMBER}*\s*(.+)?/
  UNIT_STRING_REGEX = /#{SCI_NUMBER}*\s*([^\/]*)\/*(.+)*/
  TOP_REGEX = /([^ \*]+)(?:\^|\*\*)([\d-]+)/
  BOTTOM_REGEX = /([^* ]+)(?:\^|\*\*)(\d+)/
  UNCERTAIN_REGEX = /#{SCI_NUMBER}\s*\+\/-\s*#{SCI_NUMBER}\s(.+)/
  COMPLEX_REGEX = /#{COMPLEX_NUMBER}\s?(.+)?/
  RATIONAL_REGEX = /#{RATIONAL_NUMBER}\s?(.+)?/
  KELVIN = ['<kelvin>']
  FAHRENHEIT = ['<fahrenheit>']
  RANKINE = ['<rankine>']
  CELSIUS = ['<celsius>']

  SIGNATURE_VECTOR = [:length, :time, :temperature, :mass, :current, :substance, :luminosity, :currency, :memory, :angle, :capacitance]
  @@KINDS = {
    -312058=>:resistance, 
    -312038=>:inductance, 
    -152040=>:magnetism, 
    -152038=>:magnetism, 
    -152058=>:potential, 
    -39=>:acceleration,
    -38=>:radiation, 
    -20=>:frequency, 
    -19=>:speed, 
    -18=>:viscosity, 
    0=>:unitless, 
    1=>:length, 
    2=>:area, 
    3=>:volume, 
    20=>:time, 
    400=>:temperature, 
    7942=>:power, 
    7959=>:pressure, 
    7962=>:energy, 
    7979=>:viscosity, 
    7981=>:force, 
    7997=>:mass_concentration,
    8000=>:mass, 
    159999=>:magnetism, 
    160000=>:current, 
    160020=>:charge, 
    312058=>:resistance, 
    3199980=>:activity, 
    3199997=>:molar_concentration, 
    3200000=>:substance, 
    63999998=>:illuminance, 
    64000000=>:luminous_power, 
    1280000000=>:currency, 
    25600000000=>:memory,
    511999999980=>:angular_velocity, 
    512000000000=>:angle, 
    10240000000000=>:capacitance, 
    }
  
  @@cached_units = {}
  @@base_unit_cache = {}
  
  def self.setup
    @@ALL_UNIT_DEFINITIONS = UNIT_DEFINITIONS.merge!(@@USER_DEFINITIONS)
    for unit in (@@ALL_UNIT_DEFINITIONS) do
      key, value = unit
      if value[2] == :prefix then
        @@PREFIX_VALUES[key]=value[1]
        for name in value[0] do
          @@PREFIX_MAP[name]=key
        end    
      else
        @@UNIT_VALUES[key]={}
        @@UNIT_VALUES[key][:scalar]=value[1]
        @@UNIT_VALUES[key][:numerator]=value[3] if value[3]
        @@UNIT_VALUES[key][:denominator]=value[4] if value[4]
        for name in value[0] do
          @@UNIT_MAP[name]=key
        end
      end
      @@OUTPUT_MAP[key]=value[0][0]        
    end
    @@PREFIX_REGEX = @@PREFIX_MAP.keys.sort_by {|prefix| prefix.length}.reverse.join('|')
    @@UNIT_REGEX = @@UNIT_MAP.keys.sort_by {|unit| unit.length}.reverse.join('|')
    @@UNIT_MATCH_REGEX = /(#{@@PREFIX_REGEX})*?(#{@@UNIT_REGEX})\b/    
    Unit.new(1)
  end
  
  
  include Comparable
  attr_accessor :scalar, :numerator, :denominator, :signature, :base_scalar, :base_numerator, :base_denominator, :output, :unit_name

  def to_yaml_properties
    %w{@scalar @numerator @denominator @signature @base_scalar}
  end
  
  # needed to make complex units play nice -- otherwise not detected as a complex_generic
 
  def kind_of?(klass)
    self.scalar.kind_of?(klass)
  end
 
  def copy(from)
    @scalar = from.scalar
    @numerator = from.numerator
    @denominator = from.denominator
    @is_base = from.is_base?
    @signature = from.signature
    @base_scalar = from.base_scalar
    @output = from.output rescue nil
    @unit_name = from.unit_name rescue nil
  end
  
  # basically a copy of the basic to_yaml.  Needed because otherwise it ends up coercing the object to a string
  # before YAML'izing it.
  def to_yaml( opts = {} )
    YAML::quick_emit( object_id, opts ) do |out|
      out.map( taguri, to_yaml_style ) do |map|
        for m in to_yaml_properties do 
          map.add( m[1..-1], instance_variable_get( m ) )
        end
      end
    end
  end
  
  # Create a new Unit object.  Can be initialized using a string, or a hash
  # Valid formats include:
  #  "5.6 kg*m/s^2"
  #  "5.6 kg*m*s^-2"
  #  "5.6 kilogram*meter*second^-2"
  #  "2.2 kPa"
  #  "37 degC"
  #  "1"  -- creates a unitless constant with value 1
  #  "GPa"  -- creates a unit with scalar 1 with units 'GPa'
  #  6'4"  -- recognized as 6 feet + 4 inches 
  #  8 lbs 8 oz -- recognized as 8 lbs + 8 ounces
  #
  def initialize(*options)
    @scalar = nil
    @base_scalar = nil
    @unit_name = nil
    @signature = nil
    @output = nil
    if options.size == 2
      begin
        cached = @@cached_units[options[1]] * options[0] 
        copy(cached)
      rescue 
        initialize("#{options[0]} #{(options[1].units rescue options[1])}")
      end
      return
    end
    if options.size == 3
      begin
        cached = @@cached_units["#{options[1]}/#{options[2]}"] * options[0] 
        copy(cached)
      rescue 
        initialize("#{options[0]} #{options[1]}/#{options[2]}")
      end
      return
    end
    
    case options[0]
    when Hash:
      @scalar = options[0][:scalar] || 1
      @numerator = options[0][:numerator] || UNITY_ARRAY
      @denominator = options[0][:denominator] || UNITY_ARRAY
      @signature = options[0][:signature]
    when Array:
      initialize(*options[0])
      return
    when Numeric:
      @scalar = options[0]
      @numerator = @denominator = UNITY_ARRAY
    when Time:
      @scalar = options[0].to_f
      @numerator = ['<second>']
      @denominator = UNITY_ARRAY
    when DateTime:
      @scalar = options[0].ajd
      @numerator = ['<day>']
      @denominator = UNITY_ARRAY
    when "": raise ArgumentError, "No Unit Specified"
    when String: parse(options[0])   
    else
      raise ArgumentError, "Invalid Unit Format"
    end
    self.update_base_scalar
    raise ArgumentError, "Temperature out of range" if self.is_temperature? &&  self.base_scalar < 0
  
    unary_unit = self.units || ""
    opt_units = options[0].scan(NUMBER_REGEX)[0][1] if String === options[0]
    unless @@cached_units.keys.include?(opt_units) || (opt_units =~ /(temp|deg(C|K|R|F))|(pounds|lbs[ ,]\d+ ounces|oz)|('\d+")|(ft|feet[ ,]\d+ in|inch|inches)|%|(#{TIME_REGEX})|i\s?(.+)?|&plusmn;|\+\/-/)
      @@cached_units[opt_units] = (self.scalar == 1 ? self : opt_units.unit) if opt_units && !opt_units.empty?
    end
    unless @@cached_units.keys.include?(unary_unit) || (unary_unit =~ /(temp|deg)(C|K|R|F)/) then
      @@cached_units[unary_unit] = (self.scalar == 1 ? self : unary_unit.unit)
    end
    [@scalar, @numerator, @denominator, @base_scalar, @signature, @is_base].each {|x| x.freeze}
    self
  end

  def kind
    return @@KINDS[self.signature]
  end
  
  def self.cached
    return @@cached_units
  end
  
  def self.clear_cache
    @@cached_units = {}
    @@base_unit_cache = {}
  end
    
  def self.base_unit_cache
    return @@base_unit_cache
  end
  
  def self.parse(input)
    first, second = input.scan(/(.+)\s(?:in|to|as)\s(.+)/i).first
    second.nil? ? first.unit : first.unit.to(second)
  end
  
  def to_unit
    self
  end
  alias :unit :to_unit
  
  # Returns 'true' if the Unit is represented in base units
  def is_base?
    return @is_base if defined? @is_base
    return @is_base=true if @signature == 400 && self.numerator.size == 1 && self.denominator == UNITY_ARRAY && self.units =~ /(deg|temp)K/
    n = @numerator + @denominator
    for x in n.compact do 
      return @is_base=false unless x == UNITY || (@@BASE_UNITS.include?((x)))
    end
    return @is_base = true
  end  
  
  # convert to base SI units
  # results of the conversion are cached so subsequent calls to this will be fast
  def to_base
    return self if self.is_base?
     if self.units =~ /\A(deg|temp)(C|F|K|C)\Z/
      @signature = 400
      base = case self.units
      when /temp/ : self.to('tempK')
      when /deg/ : self.to('degK')
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
          q /= @@PREFIX_VALUES[unit]
        else
          q /= @@UNIT_VALUES[unit][:scalar] if @@UNIT_VALUES[unit]
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
  
  # Generate human readable output.
  # If the name of a unit is passed, the unit will first be converted to the target unit before output.
  # some named conversions are available
  #
  #  :ft - outputs in feet and inches (e.g., 6'4")
  #  :lbs - outputs in pounds and ounces (e.g, 8 lbs, 8 oz)
  #  
  # You can also pass a standard format string (i.e., '%0.2f')
  # or a strftime format string.
  #
  # output is cached so subsequent calls for the same format will be fast
  #
  def to_s(target_units=nil)
    out = @output[target_units] rescue nil
    if out
      return out
    else
      case target_units
      when :ft:
        inches = self.to("in").scalar.to_int
        out = "#{(inches / 12).truncate}\'#{(inches % 12).round}\""
      when :lbs:
        ounces = self.to("oz").scalar.to_int
        out = "#{(ounces / 16).truncate} lbs, #{(ounces % 16).round} oz"
      when String
        begin #first try a standard format string
          target_units =~ /(%[\w\d#+-.]*)*\s*(.+)*/
          out = $2 ? self.to($2).to_s($1) : "#{($1 || '%g') % @scalar || 0} #{self.units}".strip
        rescue #if that is malformed, try a time string
          out = (Time.gm(0) + self).strftime(target_units)
        end
      else
        out = case @scalar
        when Rational : 
          "#{@scalar} #{self.units}"
        else
          "#{'%g' % @scalar} #{self.units}"
        end.strip
      end
      @output = {target_units => out}
      return out
    end    
  end
  
  # Normally pretty prints the unit, but if you really want to see the guts of it, pass ':dump'
  def inspect(option=nil)
    return super() if option == :dump
    self.to_s
  end
  
  # true if unit is a 'temperature', false if a 'degree' or anything else
  def is_temperature?
    return true if self.signature == 400 && self.units =~ /temp/
  end
  
  # returns the 'degree' unit associated with a temperature unit
  # '100 tempC'.unit.temperature_scale #=> 'degC'
  def temperature_scale
    return nil unless self.is_temperature?
    self.units =~ /temp(C|F|R|K)/
    "deg#{$1}"
  end
  
  # returns true if no associated units
  # false, even if the units are "unitless" like 'radians, each, etc'
  def unitless?
    (@numerator == UNITY_ARRAY && @denominator == UNITY_ARRAY)
  end
  
  # Compare two Unit objects. Throws an exception if they are not of compatible types.
  # Comparisons are done based on the value of the unit in base SI units.
  def <=>(other)
    case other
    when 0: self.base_scalar <=> 0
    when Unit:
      raise ArgumentError, "Incompatible Units" unless self =~ other
      self.base_scalar <=> other.base_scalar
    else
      x,y = coerce(other)
      x <=> y
    end
  end
  
  # check to see if units are compatible, but not the scalar part
  # this check is done by comparing signatures for performance reasons
  # if passed a string, it will create a unit object with the string and then do the comparison
  # this permits a syntax like:  
  #  unit =~ "mm"
  # if you want to do a regexp on the unit string do this ...
  #  unit.units =~ /regexp/
  def =~(other)
    return true if self == 0 || other == 0
    case other
    when Unit : self.signature == other.signature
    else
      x,y = coerce(other)
      x =~ y
    end 
  end
  
  alias :compatible? :=~
  alias :compatible_with? :=~
  
  # Compare two units.  Returns true if quantities and units match
  #
  # Unit("100 cm") === Unit("100 cm")   # => true
  # Unit("100 cm") === Unit("1 m")      # => false
  def ===(other)
    case other
    when Unit: (self.scalar == other.scalar) && (self.units == other.units)
    else
      x,y = coerce(other)
      x === y
    end
  end
  
  alias :same? :===
  alias :same_as? :===
  
  # Add two units together.  Result is same units as receiver and scalar and base_scalar are updated appropriately
  # throws an exception if the units are not compatible.
  # It is possible to add Time objects to units of time
  def +(other)   
    if Unit === other 
      case
      when self.zero? : other.dup
      when self =~ other :
        raise ArgumentError, "Cannot add two temperatures" if ([self, other].all? {|x| x.is_temperature?})
        if [self, other].any? {|x| x.is_temperature?}
          case self.is_temperature?
          when true:
            Unit.new(:scalar => (self.scalar + other.to(self.temperature_scale).scalar), :numerator => @numerator, :denominator=>@denominator, :signature => @signature)
          else
            Unit.new(:scalar => (other.scalar + self.to(other.temperature_scale).scalar), :numerator => other.numerator, :denominator=>other.denominator, :signature => other.signature)
          end
        else
          @q ||= ((@@cached_units[self.units].scalar / @@cached_units[self.units].base_scalar) rescue (self.units.unit.to_base.scalar))
          Unit.new(:scalar=>(self.base_scalar + other.base_scalar)*@q, :numerator=>@numerator, :denominator=>@denominator, :signature => @signature)
        end
      else
         raise ArgumentError,  "Incompatible Units ('#{self}' not compatible with '#{other}')"
      end
    elsif Time === other
      other + self
    else
        x,y = coerce(other)
        y + x
    end
  end
  
  # Subtract two units. Result is same units as receiver and scalar and base_scalar are updated appropriately
  # throws an exception if the units are not compatible.
  def -(other)
    if Unit === other 
    case
      when self.zero? : -other.dup
      when self =~ other :
        case
          when [self, other].all? {|x| x.is_temperature?} : 
            Unit.new(:scalar => (self.base_scalar - other.base_scalar), :numerator  => KELVIN, :denominator => UNITY_ARRAY, :signature => @signature).to(self.temperature_scale) 
          when self.is_temperature? :
            Unit.new(:scalar => (self.base_scalar - other.base_scalar), :numerator  => ['<temp-K>'], :denominator => UNITY_ARRAY, :signature => @signature).to(self) 
          when other.is_temperature? :
            raise ArgumentError, "Cannot subtract a temperature from a differential degree unit"
          else
            @q ||= ((@@cached_units[self.units].scalar / @@cached_units[self.units].base_scalar) rescue (self.units.unit.scalar/self.units.unit.to_base.scalar))
            Unit.new(:scalar=>(self.base_scalar - other.base_scalar)*@q, :numerator=>@numerator, :denominator=>@denominator, :signature=>@signature)            
        end
      else
         raise ArgumentError,  "Incompatible Units ('#{self}' not compatible with '#{other}')"
      end
    elsif Time === other
      other - self
    else
        x,y = coerce(other)
        y-x
    end
  end
  
  # Multiply two units.
  def *(other)
    case other
    when Unit
      raise ArgumentError, "Cannot multiply by temperatures" if [other,self].any? {|x| x.is_temperature?}
      opts = Unit.eliminate_terms(@scalar*other.scalar, @numerator + other.numerator ,@denominator + other.denominator)
      opts.merge!(:signature => @signature + other.signature)
      Unit.new(opts)      
    when Numeric
      Unit.new(:scalar=>@scalar*other, :numerator=>@numerator, :denominator=>@denominator, :signature => @signature)
    else
      x,y = coerce(other)
      x * y
    end
  end
  
  # Divide two units.
  # Throws an exception if divisor is 0
  def /(other)
    case other
    when Unit 
      raise ZeroDivisionError if other.zero?
      raise ArgumentError, "Cannot divide with temperatures" if [other,self].any? {|x| x.is_temperature?}
      opts = Unit.eliminate_terms(@scalar/other.scalar, @numerator + other.denominator ,@denominator + other.numerator)
      opts.merge!(:signature=> @signature - other.signature)
      Unit.new(opts)      
    when Numeric
      raise ZeroDivisionError if other.zero?
      Unit.new(:scalar=>@scalar/other, :numerator=>@numerator, :denominator=>@denominator, :signature => @signature)      
    else
      x,y = coerce(other)
      y / x
    end
  end
    
  # Exponentiate.  Only takes integer powers. 
  # Note that anything raised to the power of 0 results in a Unit object with a scalar of 1, and no units.
  # Throws an exception if exponent is not an integer.
  # Ideally this routine should accept a float for the exponent
  # It should then convert the float to a rational and raise the unit by the numerator and root it by the denominator
  # but, sadly, floats can't be converted to rationals.
  #
  # For now, if a rational is passed in, it will be used, otherwise we are stuck with integers and certain floats < 1
  def **(other)
    raise ArgumentError, "Cannot raise a temperature to a power" if self.is_temperature?
    if Numeric === other
      return Unit("1") if other.zero?
      return self if other == 1
      return self.inverse if other == -1
    end
    case other
    when Rational:
      self.power(other.numerator).root(other.denominator)
    when Integer:
      self.power(other)
    when Float:
      return self**(other.to_i) if other == other.to_i
      valid = (1..9).map {|x| 1/x}
      raise ArgumentError, "Not a n-th root (1..9), use 1/n" unless valid.include? other.abs
      self.root((1/other).to_int)
    else
      raise ArgumentError, "Invalid Exponent"
    end
  end

  # returns the unit raised to the n-th power.  Integers only
  def power(n)
    raise ArgumentError, "Cannot raise a temperature to a power" if self.is_temperature?
    raise ArgumentError, "Can only use Integer exponenents" unless Integer === n
    return self if n == 1
    return Unit("1") if n == 0
    return self.inverse if n == -1
    if n > 0 then 
      (1..(n-1).to_i).inject(self) {|product, x| product * self}
    else
      (1..-(n-1).to_i).inject(self) {|product, x| product / self}
    end
  end
  
  # Calculates the n-th root of a unit, where n = (1..9)
  # if n < 0, returns 1/unit^(1/n)
  def root(n)
    raise ArgumentError, "Cannot take the root of a temperature" if self.is_temperature?
    raise ArgumentError, "Exponent must an Integer" unless Integer === n
    raise ArgumentError, "0th root undefined" if n == 0
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
      r.times {|x| num.delete_at(num.index(item))}
    end
    
    for item in @denominator.uniq do 
      x = den.find_all {|i| i==item}.size
      r = ((x/n)*(n-1)).to_int
      r.times {|x| den.delete_at(den.index(item))}
    end
    q = @scalar < 0 ? (-1)**Rational(1,n) * (@scalar.abs)**Rational(1,n) : @scalar**Rational(1,n)
    Unit.new(:scalar=>q,:numerator=>num,:denominator=>den)    
  end
  
  # returns inverse of Unit (1/unit)
  def inverse
    Unit("1") / self
  end
  
  # convert to a specified unit string or to the same units as another Unit
  # 
  #  unit >> "kg"  will covert to kilograms
  #  unit1 >> unit2 converts to same units as unit2 object
  # 
  # To convert a Unit object to match another Unit object, use:
  #  unit1 >>= unit2
  # Throws an exception if the requested target units are incompatible with current Unit.
  #
  # Special handling for temperature conversions is supported.  If the Unit object is converted
  # from one temperature unit to another, the proper temperature offsets will be used.
  # Supports Kelvin, Celcius, fahrenheit, and Rankine scales.
  #
  # Note that if temperature is part of a compound unit, the temperature will be treated as a differential
  # and the units will be scaled appropriately.
  def to(other)
    return self if other.nil? 
    return self if TrueClass === other
    return self if FalseClass === other
    if (Unit === other && other.is_temperature?) || (String === other && other =~ /temp(K|C|R|F)/) 
      raise ArgumentError, "Receiver is not a temperature unit" unless self.signature == 400 
      start_unit = self.units
      target_unit = other.units rescue other
      unless @base_scalar
        @base_scalar = case start_unit
          when 'tempC' : @scalar + 273.15
          when 'tempK' : @scalar
          when 'tempF' : (@scalar+459.67)*(5.0/9.0)
          when 'tempR' : @scalar*(5.0/9.0)
        end
      end
      q=  case target_unit
            when 'tempC'  : @base_scalar - 273.15
            when 'tempK'  : @base_scalar 
            when 'tempF'  : @base_scalar * (9.0/5.0) - 459.67
            when 'tempR'  : @base_scalar * (9.0/5.0) 
          end
        
      Unit.new("#{q} #{target_unit}")
    else
       case other
          when Unit: 
            return self if other.units == self.units
            target = other
          when String: target = Unit.new(other)
          else
            raise ArgumentError, "Unknown target units"
        end
      raise ArgumentError,  "Incompatible Units" unless self =~ target
      one = @numerator.map {|x| @@PREFIX_VALUES[x] ? @@PREFIX_VALUES[x] : x}.map {|i| i.kind_of?(Numeric) ? i : @@UNIT_VALUES[i][:scalar] }.compact
      two = @denominator.map {|x| @@PREFIX_VALUES[x] ? @@PREFIX_VALUES[x] : x}.map {|i| i.kind_of?(Numeric) ? i : @@UNIT_VALUES[i][:scalar] }.compact
      v = one.inject(1) {|product,n| product*n} / two.inject(1) {|product,n| product*n}
      one = target.numerator.map {|x| @@PREFIX_VALUES[x] ? @@PREFIX_VALUES[x] : x}.map {|x| x.kind_of?(Numeric) ? x : @@UNIT_VALUES[x][:scalar] }.compact
      two = target.denominator.map {|x| @@PREFIX_VALUES[x] ? @@PREFIX_VALUES[x] : x}.map {|x| x.kind_of?(Numeric) ? x : @@UNIT_VALUES[x][:scalar] }.compact
      y = one.inject(1) {|product,n| product*n} / two.inject(1) {|product,n| product*n}
      q = @scalar * v/y
      Unit.new(:scalar=>q, :numerator=>target.numerator, :denominator=>target.denominator, :signature => target.signature)
    end
  end  
  alias :>> :to
  alias :convert_to :to
    
  # converts the unit back to a float if it is unitless.  Otherwise raises an exception
  def to_f
    return @scalar.to_f if self.unitless?
    raise RuntimeError, "Can't convert to Float unless unitless.  Use Unit#scalar"
  end
  
  # converts the unit back to a complex if it is unitless.  Otherwise raises an exception
  
  def to_c
    return Complex(@scalar) if self.unitless?
    raise RuntimeError, "Can't convert to Complex unless unitless.  Use Unit#scalar"
  end
  
  # returns the 'unit' part of the Unit object without the scalar
  def units
    return "" if @numerator == UNITY_ARRAY && @denominator == UNITY_ARRAY
    return @unit_name unless @unit_name.nil?
    output_n = []
    output_d =[] 
    num = @numerator.clone.compact
    den = @denominator.clone.compact
    if @numerator == UNITY_ARRAY
      output_n << "1"
    else
      num.each_with_index do |token,index|
        if token && @@PREFIX_VALUES[token] then
          output_n << "#{@@OUTPUT_MAP[token]}#{@@OUTPUT_MAP[num[index+1]]}"
          num[index+1]=nil
        else
          output_n << "#{@@OUTPUT_MAP[token]}" if token
        end
      end
    end
    if @denominator == UNITY_ARRAY
      output_d = ['1']
    else
      den.each_with_index do |token,index|
          if token && @@PREFIX_VALUES[token] then
            output_d << "#{@@OUTPUT_MAP[token]}#{@@OUTPUT_MAP[den[index+1]]}"
            den[index+1]=nil
          else
            output_d << "#{@@OUTPUT_MAP[token]}" if token
          end
        end
    end
    on = output_n.reject {|x| x.empty?}.map {|x| [x, output_n.find_all {|z| z==x}.size]}.uniq.map {|x| ("#{x[0]}".strip+ (x[1] > 1 ? "^#{x[1]}" : ''))}
    od = output_d.reject {|x| x.empty?}.map {|x| [x, output_d.find_all {|z| z==x}.size]}.uniq.map {|x| ("#{x[0]}".strip+ (x[1] > 1 ? "^#{x[1]}" : ''))}
    out = "#{on.join('*')}#{od == ['1'] ? '': '/'+od.join('*')}".strip    
    @unit_name = out unless self.kind == :temperature
    return out
  end
  
  # negates the scalar of the Unit
  def -@
    return -@scalar if self.unitless?
    self.dup * -1
  end
  
  # returns abs of scalar, without the units
  def abs
    return @scalar.abs
  end
  
  def ceil
    return @scalar.ceil if self.unitless?
    Unit.new(@scalar.ceil, @numerator, @denominator)    
  end
  
  def floor
    return @scalar.floor if self.unitless?
    Unit.new(@scalar.floor, @numerator, @denominator)    
  end

  # if unitless, returns an int, otherwise raises an error
  def to_i
    return @scalar.to_int if self.unitless?
    raise RuntimeError, 'Cannot convert to Integer unless unitless'
  end
  alias :to_int :to_i
  
  # Tries to make a Time object from current unit.  Assumes the current unit hold the duration in seconds from the epoch.
  def to_time
    Time.at(self)
  end
  alias :time :to_time

  def truncate
    return @scalar.truncate if self.unitless?
    Unit.new(@scalar.truncate, @numerator, @denominator)    
  end

  # convert a duration to a DateTime.  This will work so long as the duration is the duration from the zero date
  # defined by DateTime
  def to_datetime
    DateTime.new0(self.to('d').scalar)
  end
  
  def to_date
    Date.new0(self.to('d').scalar)
  end
  
  def round
    return @scalar.round if self.unitless?
    Unit.new(@scalar.round, @numerator, @denominator)    
  end
   
  # true if scalar is zero
  def zero?
    return @scalar.zero?
  end
  
  # '5 min'.unit.ago 
  def ago
    self.before
  end
  
  # '5 min'.before(time)
  def before(time_point = ::Time.now)
    raise ArgumentError, "Must specify a Time" unless time_point
    if String === time_point
      time_point.time - self rescue time_point.datetime - self
    else
      time_point - self rescue time_point.to_datetime - self
    end
  end
  alias :before_now :before
  
  # 'min'.since(time)
  def since(time_point = ::Time.now)
    case time_point
    when Time:      (Time.now - time_point).unit('s').to(self)
    when DateTime, Date:  (DateTime.now - time_point).unit('d').to(self)
    when String:    
      (DateTime.now - time_point.time(:context=>:past)).unit('d').to(self)
    else
      raise ArgumentError, "Must specify a Time, DateTime, or String" 
    end
  end
  
  # 'min'.until(time)
  def until(time_point = ::Time.now)
    case time_point
    when Time:      (time_point - Time.now).unit('s').to(self)
    when DateTime, Date:  (time_point - DateTime.now).unit('d').to(self)
    when String:
      r = (time_point.time(:context=>:future) - DateTime.now)
      Time === time_point.time ? r.unit('s').to(self) : r.unit('d').to(self)
    else
      raise ArgumentError, "Must specify a Time, DateTime, or String" 
    end
  end
  
  # '5 min'.from(time)
  def from(time_point = ::Time.now)
    raise ArgumentError, "Must specify a Time" unless time_point
    if String === time_point
      time_point.time + self rescue time_point.datetime + self
    else
      time_point + self rescue time_point.to_datetime + self
    end
  end
  alias :after :from
  alias :from_now :from
  
  # returns next unit in a range.  '1 mm'.unit.succ #=> '2 mm'.unit
  # only works when the scalar is an integer    
  def succ
    raise ArgumentError, "Non Integer Scalar" unless @scalar == @scalar.to_i
    q = @scalar.to_i.succ
    Unit.new(q, @numerator, @denominator)
  end

  # automatically coerce objects to units when possible
  # if an object defines a 'to_unit' method, it will be coerced using that method
  def coerce(other)
    if other.respond_to? :to_unit
      return [other.to_unit, self]
    end
    case other
    when Unit : [other, self]
    else 
      [Unit.new(other), self]
    end
  end
      
  # Protected and Private Functions that should only be called from this class
  protected
  
  
  def update_base_scalar
    return @base_scalar unless @base_scalar.nil?
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
  def unit_signature_vector
      return self.to_base.unit_signature_vector unless self.is_base?
      result = self
      vector = Array.new(SIGNATURE_VECTOR.size,0)
      for element in @numerator
        if r=@@ALL_UNIT_DEFINITIONS[element]
            n = SIGNATURE_VECTOR.index(r[2])
           vector[n] = vector[n] + 1 if n
        end
      end
      for element in @denominator
        if r=@@ALL_UNIT_DEFINITIONS[element]
          n = SIGNATURE_VECTOR.index(r[2])
          vector[n] = vector[n] - 1 if n
        end
      end
      vector
  end
    
  private
  
  def initialize_copy(other)
    @numerator = other.numerator.dup
    @denominator = other.denominator.dup    
  end
  
  # calculates the unit signature id for use in comparing compatible units and simplification
  # the signature is based on a simple classification of units and is based on the following publication
  #  
  #  Novak, G.S., Jr. "Conversion of units of measurement", IEEE Transactions on Software Engineering,
  #  21(8), Aug 1995, pp.651-661
  #  doi://10.1109/32.403789
  #  http://ieeexplore.ieee.org/Xplore/login.jsp?url=/iel1/32/9079/00403789.pdf?isnumber=9079&prod=JNL&arnumber=403789&arSt=651&ared=661&arAuthor=Novak%2C+G.S.%2C+Jr.
  #
  def unit_signature
    return @signature unless @signature.nil?
    vector = unit_signature_vector
    vector.each_with_index {|item,index| vector[index] = item * 20**index}
    @signature=vector.inject(0) {|sum,n| sum+n}
  end
  
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
      when value > 0 : value.times {num << key}
      when value < 0 : value.abs.times {den << key}
      end
    end
    num = UNITY_ARRAY if num.empty?
    den = UNITY_ARRAY if den.empty?
    {:scalar=>q, :numerator=>num.flatten.compact, :denominator=>den.flatten.compact}
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
  def parse(passed_unit_string="0")
    unit_string = passed_unit_string.dup
    if unit_string =~ /\$\s*(#{NUMBER_REGEX})/
      unit_string = "#{$1} USD"
    end
    unit_string.gsub!(/%/,'percent')
    unit_string.gsub!(/'/,'feet')
    unit_string.gsub!(/"/,'inch')
    unit_string.gsub!(/#/,'pound')
    if defined?(Uncertain) && unit_string =~ /(\+\/-|&plusmn;)/
      value, uncertainty, unit_s = unit_string.scan(UNCERTAIN_REGEX)[0]
      result = unit_s.unit * Uncertain.new(value.to_f,uncertainty.to_f)
      copy(result)
      return  
    end
    
    if defined?(Complex) && unit_string =~ COMPLEX_NUMBER
      real, imaginary, unit_s = unit_string.scan(COMPLEX_REGEX)[0]
      result = Unit(unit_s || '1') * Complex(real.to_f,imaginary.to_f)
      copy(result)
      return 
    end
    
    if defined?(Rational) && unit_string =~ RATIONAL_NUMBER
        numerator, denominator, unit_s = unit_string.scan(RATIONAL_REGEX)[0]
        result = Unit(unit_s || '1') * Rational(numerator.to_i,denominator.to_i)
        copy(result)
        return 
    end
    
    unit_string =~ NUMBER_REGEX
    unit = @@cached_units[$2] 
    mult = ($1.empty? ? 1.0 : $1.to_f) rescue 1.0
    if unit
      copy(unit)
      @scalar *= mult
      @base_scalar *= mult
      return self
    end
  
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
    
    raise( ArgumentError, "'#{passed_unit_string}' Unit not recognized") if unit_string.count('/') > 1
    raise( ArgumentError, "'#{passed_unit_string}' Unit not recognized") if unit_string.scan(/\s\d+\S*/).size > 0
    
    @scalar, top, bottom = unit_string.scan(UNIT_STRING_REGEX)[0]  #parse the string into parts
    
    top.scan(TOP_REGEX).each do |item|
      n = item[1].to_i
      x = "#{item[0]} "
      case 
        when n>=0 : top.gsub!(/#{item[0]}(\^|\*\*)#{n}/) {|s| x * n}
        when n<0 : bottom = "#{bottom} #{x * -n}"; top.gsub!(/#{item[0]}(\^|\*\*)#{n}/,"")
      end
    end 
    bottom.gsub!(BOTTOM_REGEX) {|s| "#{$1} " * $2.to_i} if bottom
    @scalar = @scalar.to_f unless @scalar.nil? || @scalar.empty?
    @scalar = 1 unless @scalar.kind_of? Numeric 
        
    @numerator ||= UNITY_ARRAY
    @denominator ||= UNITY_ARRAY
    @numerator = top.scan(@@UNIT_MATCH_REGEX).delete_if {|x| x.empty?}.compact if top
    @denominator = bottom.scan(@@UNIT_MATCH_REGEX).delete_if {|x| x.empty?}.compact if bottom
    us = "#{(top || '' + bottom || '')}".to_s.gsub(@@UNIT_MATCH_REGEX,'').gsub(/[\d\*, "'_^\/\$]/,'')
    raise( ArgumentError, "'#{passed_unit_string}' Unit not recognized") unless us.empty?

    @numerator = @numerator.map do |item|
       @@PREFIX_MAP[item[0]] ? [@@PREFIX_MAP[item[0]], @@UNIT_MAP[item[1]]] : [@@UNIT_MAP[item[1]]]
    end.flatten.compact.delete_if {|x| x.empty?}

    @denominator = @denominator.map do |item|
       @@PREFIX_MAP[item[0]] ? [@@PREFIX_MAP[item[0]], @@UNIT_MAP[item[1]]] : [@@UNIT_MAP[item[1]]]
    end.flatten.compact.delete_if {|x| x.empty?}

    @numerator = UNITY_ARRAY if @numerator.empty? 
    @denominator = UNITY_ARRAY if @denominator.empty?
    self
  end 
end

Unit.setup
