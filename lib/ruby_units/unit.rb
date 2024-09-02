# frozen_string_literal: true

require 'date'
module RubyUnits
  # Copyright 2006-2024
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
  # in the United States. If your favorite units are not listed here, file an issue on GitHub.
  #
  # To add or override a unit definition, add a code block like this..
  # @example Define a new unit
  #  RubyUnits::Unit.define("foobar") do |unit|
  #    unit.aliases    = %w{foo fb foo-bar}
  #    unit.definition = RubyUnits::Unit.new("1 baz")
  #  end
  #
  class Unit < ::Numeric
    class << self
      # return a list of all defined units
      # @return [Hash{Symbol=>RubyUnits::Units::Definition}]
      attr_accessor :definitions

      # @return [Hash{Symbol => String}] the list of units and their prefixes
      attr_accessor :prefix_values

      # @return [Hash{Symbol => String}]
      attr_accessor :prefix_map

      # @return [Hash{Symbol => String}]
      attr_accessor :unit_map

      # @return [Hash{Symbol => String}]
      attr_accessor :unit_values

      # @return [Hash{Integer => Symbol}]
      attr_reader :kinds
    end
    self.definitions = {}
    self.prefix_values = {}
    self.prefix_map = {}
    self.unit_map = {}
    self.unit_values = {}
    @unit_regex = nil
    @unit_match_regex = nil
    UNITY              = '<1>'.freeze
    UNITY_ARRAY        = [UNITY].freeze

    SIGN_REGEX = /(?:[+-])?/.freeze # +, -, or nothing

    # regex for matching an integer number but not a fraction
    INTEGER_DIGITS_REGEX = %r{(?<!/)\d+(?!/)}.freeze # 1, 2, 3, but not 1/2 or -1
    INTEGER_REGEX = /(#{SIGN_REGEX}#{INTEGER_DIGITS_REGEX})/.freeze # -1, 1, +1, but not 1/2
    UNSIGNED_INTEGER_REGEX = /((?<!-)#{INTEGER_DIGITS_REGEX})/.freeze # 1, 2, 3, but not -1
    DIGITS_REGEX = /\d+/.freeze # 0, 1, 2, 3
    DECIMAL_REGEX = /\d*[.]?#{DIGITS_REGEX}/.freeze # 1, 0.1, .1
    # Rational number, including improper fractions: 1 2/3, -1 2/3, 5/3, etc.
    RATIONAL_NUMBER = %r{\(?(?:(?<proper>#{SIGN_REGEX}#{DECIMAL_REGEX})[ -])?(?<numerator>#{SIGN_REGEX}#{DECIMAL_REGEX})/(?<denominator>#{SIGN_REGEX}#{DECIMAL_REGEX})\)?}.freeze # 1 2/3, -1 2/3, 5/3, 1-2/3, (1/2) etc.
    # Scientific notation: 1, -1, +1, 1.2, +1.2, -1.2, 123.4E5, +123.4e5,
    #   -123.4E+5, -123.4e-5, etc.
    SCI_NUMBER = /([+-]?\d*[.]?\d+(?:[Ee][+-]?\d+(?![.]))?)/.freeze
    # ideally we would like to generate this regex from the alias for a 'feet'
    # and 'inches', but they aren't defined at the point in the code where we
    # need this regex.
    FEET_INCH_UNITS_REGEX = /(?:'|ft|feet)\s*(?<inches>#{RATIONAL_NUMBER}|#{SCI_NUMBER})\s*(?:"|in|inch(?:es)?)/.freeze
    FEET_INCH_REGEX    = /(?<feet>#{INTEGER_REGEX})\s*#{FEET_INCH_UNITS_REGEX}/.freeze
    # ideally we would like to generate this regex from the alias for a 'pound'
    # and 'ounce', but they aren't defined at the point in the code where we
    # need this regex.
    LBS_OZ_UNIT_REGEX  = /(?:#|lbs?|pounds?|pound-mass)+[\s,]*(?<oz>#{RATIONAL_NUMBER}|#{UNSIGNED_INTEGER_REGEX})\s*(?:ozs?|ounces?)/.freeze
    LBS_OZ_REGEX       = /(?<pounds>#{INTEGER_REGEX})\s*#{LBS_OZ_UNIT_REGEX}/.freeze
    # ideally we would like to generate this regex from the alias for a 'stone'
    # and 'pound', but they aren't defined at the point in the code where we
    # need this regex. also note that the plural of 'stone' is still 'stone',
    # but we accept 'stones' anyway.
    STONE_LB_UNIT_REGEX = /(?:sts?|stones?)+[\s,]*(?<pounds>#{RATIONAL_NUMBER}|#{UNSIGNED_INTEGER_REGEX})\s*(?:#|lbs?|pounds?|pound-mass)*/.freeze
    STONE_LB_REGEX     = /(?<stone>#{INTEGER_REGEX})\s*#{STONE_LB_UNIT_REGEX}/.freeze
    # Time formats: 12:34:56,78, (hh:mm:ss,msec) etc.
    TIME_REGEX         = /(?<hour>\d+):(?<min>\d+):?(?:(?<sec>\d+))?(?:[.](?<msec>\d+))?/.freeze
    # Complex numbers: 1+2i, 1.0+2.0i, -1-1i, etc.
    COMPLEX_NUMBER     = /(?<real>#{SCI_NUMBER})?(?<imaginary>#{SCI_NUMBER})i\b/.freeze
    # Any Complex, Rational, or scientific number
    ANY_NUMBER         = /(#{COMPLEX_NUMBER}|#{RATIONAL_NUMBER}|#{SCI_NUMBER})/.freeze
    ANY_NUMBER_REGEX   = /(?:#{ANY_NUMBER})?\s?([^-\d.].*)?/.freeze
    NUMBER_REGEX       = /(?<scalar>#{SCI_NUMBER}*)\s*(?<unit>.+)?/.freeze # a number followed by a unit
    UNIT_STRING_REGEX  = %r{#{SCI_NUMBER}*\s*([^/]*)/*(.+)*}.freeze
    TOP_REGEX          = /([^ *]+)(?:\^|\*\*)([\d-]+)/.freeze
    BOTTOM_REGEX       = /([^* ]+)(?:\^|\*\*)(\d+)/.freeze
    NUMBER_UNIT_REGEX  = /#{SCI_NUMBER}?(.*)/.freeze
    COMPLEX_REGEX      = /#{COMPLEX_NUMBER}\s?(?<unit>.+)?/.freeze
    RATIONAL_REGEX     = /#{RATIONAL_NUMBER}\s?(?<unit>.+)?/.freeze
    KELVIN             = ['<kelvin>'].freeze
    FAHRENHEIT         = ['<fahrenheit>'].freeze
    RANKINE            = ['<rankine>'].freeze
    CELSIUS            = ['<celsius>'].freeze
    @temp_regex = nil
    SIGNATURE_VECTOR = %i[
      length
      time
      temperature
      mass
      current
      substance
      luminosity
      currency
      information
      angle
    ].freeze
    @kinds = {
      -312_078 => :elastance,
      -312_058 => :resistance,
      -312_038 => :inductance,
      -152_040 => :magnetism,
      -152_038 => :magnetism,
      -152_058 => :potential,
      -7997 => :specific_volume,
      -79 => :snap,
      -59 => :jolt,
      -39 => :acceleration,
      -38 => :radiation,
      -20 => :frequency,
      -19 => :speed,
      -18 => :viscosity,
      -17 => :volumetric_flow,
      -1 => :wavenumber,
      0 => :unitless,
      1 => :length,
      2 => :area,
      3 => :volume,
      20 => :time,
      400 => :temperature,
      7941 => :yank,
      7942 => :power,
      7959 => :pressure,
      7962 => :energy,
      7979 => :viscosity,
      7961 => :force,
      7981 => :momentum,
      7982 => :angular_momentum,
      7997 => :density,
      7998 => :area_density,
      8000 => :mass,
      152_020 => :radiation_exposure,
      159_999 => :magnetism,
      160_000 => :current,
      160_020 => :charge,
      312_058 => :conductance,
      312_078 => :capacitance,
      3_199_980 => :activity,
      3_199_997 => :molar_concentration,
      3_200_000 => :substance,
      63_999_998 => :illuminance,
      64_000_000 => :luminous_power,
      1_280_000_000 => :currency,
      25_600_000_000 => :information,
      511_999_999_980 => :angular_velocity,
      512_000_000_000 => :angle
    }.freeze

    # Class Methods

    # Callback triggered when a subclass is created. This properly sets up the internal variables, and copies
    # definitions from the parent class.
    #
    # @param [Class] subclass
    def self.inherited(subclass)
      super
      subclass.definitions = definitions.dup
      subclass.instance_variable_set(:@kinds, @kinds.dup)
      subclass.setup
    end

    # setup internal arrays and hashes
    # @return [Boolean]
    def self.setup
      clear_cache
      self.prefix_values = {}
      self.prefix_map = {}
      self.unit_map = {}
      self.unit_values = {}
      @unit_regex = nil
      @unit_match_regex = nil
      @prefix_regex = nil

      definitions.each_value do |definition|
        use_definition(definition)
      end

      new(1)
      true
    end

    # determine if a unit is already defined
    # @param [String] unit
    # @return [Boolean]
    def self.defined?(unit)
      definitions.values.any? { _1.aliases.include?(unit) }
    end

    # return the unit definition for a unit
    # @param unit_name [String]
    # @return [RubyUnits::Unit::Definition, nil]
    def self.definition(unit_name)
      unit = unit_name =~ /^<.+>$/ ? unit_name : "<#{unit_name}>"
      definitions[unit]
    end

    # @param  [RubyUnits::Unit::Definition, String] unit_definition
    # @param  [Proc] block
    # @return [RubyUnits::Unit::Definition]
    # @raise  [ArgumentError] when passed a non-string if using the block form
    # Unpack a unit definition and add it to the array of defined units
    #
    # @example Block form
    #   RubyUnits::Unit.define('foobar') do |foobar|
    #     foobar.definition = RubyUnits::Unit.new("1 baz")
    #   end
    #
    # @example RubyUnits::Unit::Definition form
    #   unit_definition = RubyUnits::Unit::Definition.new("foobar") {|foobar| foobar.definition = RubyUnits::Unit.new("1 baz")}
    #   RubyUnits::Unit.define(unit_definition)
    def self.define(unit_definition, &block)
      if block_given?
        raise ArgumentError, 'When using the block form of RubyUnits::Unit.define, pass the name of the unit' unless unit_definition.is_a?(String)

        unit_definition = RubyUnits::Unit::Definition.new(unit_definition, &block)
      end
      definitions[unit_definition.name] = unit_definition
      use_definition(unit_definition)
      unit_definition
    end

    # Get the definition for a unit and allow it to be redefined
    #
    # @param [String] name Name of unit to redefine
    # @param [Proc] _block
    # @raise [ArgumentError] if a block is not given
    # @yieldparam [RubyUnits::Unit::Definition] the definition of the unit being
    #   redefined
    # @return (see RubyUnits::Unit.define)
    def self.redefine!(name, &_block)
      raise ArgumentError, 'A block is required to redefine a unit' unless block_given?

      unit_definition = definition(name)
      raise(ArgumentError, "'#{name}' Unit not recognized") unless unit_definition

      yield unit_definition
      definitions.delete("<#{name}>")
      define(unit_definition)
      setup
    end

    # Undefine a unit.  Will not raise an exception for unknown units.
    #
    # @param unit [String] name of unit to undefine
    # @return (see RubyUnits::Unit.setup)
    def self.undefine!(unit)
      definitions.delete("<#{unit}>")
      setup
    end

    # Unit cache
    #
    # @return [RubyUnits::Cache]
    def self.cached
      @cached ||= RubyUnits::Cache.new
    end

    # @return [Boolean]
    def self.clear_cache
      cached.clear
      base_unit_cache.clear
      new(1)
      true
    end

    # @return [RubyUnits::Cache]
    def self.base_unit_cache
      @base_unit_cache ||= RubyUnits::Cache.new
    end

    # @example parse strings
    #   "1 minute in seconds"
    # @param [String] input
    # @return [Unit]
    def self.parse(input)
      first, second = input.scan(/(.+)\s(?:in|to|as)\s(.+)/i).first
      second.nil? ? new(first) : new(first).convert_to(second)
    end

    # @param q [Numeric] quantity
    # @param n [Array] numerator
    # @param d [Array] denominator
    # @return [Hash]
    def self.eliminate_terms(q, n, d)
      num = n.dup
      den = d.dup
      num.delete(UNITY)
      den.delete(UNITY)

      combined = ::Hash.new(0)

      [[num, 1], [den, -1]].each do |array, increment|
        array.chunk_while { |elt_before, _| definition(elt_before).prefix? }
             .to_a
             .each { combined[_1] += increment }
      end

      num = []
      den = []
      combined.each do |key, value|
        if value.positive?
          value.times { num << key }
        elsif value.negative?
          value.abs.times { den << key }
        end
      end
      num = UNITY_ARRAY if num.empty?
      den = UNITY_ARRAY if den.empty?
      { scalar: q, numerator: num.flatten, denominator: den.flatten }
    end

    # Creates a new unit from the current one with all common terms eliminated.
    #
    # @return [RubyUnits::Unit]
    def eliminate_terms
      self.class.new(self.class.eliminate_terms(@scalar, @numerator, @denominator))
    end

    # return an array of base units
    # @return [Array]
    def self.base_units
      @base_units ||= definitions.dup.select { |_, definition| definition.base? }.keys.map { new(_1) }
    end

    # Parse a string consisting of a number and a unit string
    # NOTE: This does not properly handle units formatted like '12mg/6ml'
    #
    # @param [String] string
    # @return [Array(Numeric, String)] consisting of [number, "unit"]
    def self.parse_into_numbers_and_units(string)
      num, unit = string.scan(ANY_NUMBER_REGEX).first

      [
        case num
        when nil # This happens when no number is passed and we are parsing a pure unit string
          1
        when COMPLEX_NUMBER
          num.to_c
        when RATIONAL_NUMBER
          # We use this method instead of relying on `to_r` because it does not
          # handle improper fractions correctly.
          sign = Regexp.last_match(1) == '-' ? -1 : 1
          n = Regexp.last_match(2).to_i
          f = Rational(Regexp.last_match(3).to_i, Regexp.last_match(4).to_i)
          sign * (n + f)
        else
          num.to_f
        end,
        unit.to_s.strip
      ]
    end

    # return a fragment of a regex to be used for matching units or reconstruct it if hasn't been used yet.
    # Unit names are reverse sorted by length so the regexp matcher will prefer longer and more specific names
    # @return [String]
    def self.unit_regex
      @unit_regex ||= unit_map.keys.sort_by { [_1.length, _1] }.reverse.join('|')
    end

    # return a regex used to match units
    # @return [Regexp]
    def self.unit_match_regex
      @unit_match_regex ||= /(#{prefix_regex})??(#{unit_regex})\b/
    end

    # return a regexp fragment used to match prefixes
    # @return [String]
    # @private
    def self.prefix_regex
      @prefix_regex ||= prefix_map.keys.sort_by { [_1.length, _1] }.reverse.join('|')
    end

    # Generates (and memoizes) a regexp matching any of the temperature units or their aliases.
    #
    # @return [Regexp]
    def self.temp_regex
      @temp_regex ||= begin
        temp_units = %w[tempK tempC tempF tempR degK degC degF degR]
        aliases = temp_units.map do |unit|
          d = definition(unit)
          d && d.aliases
        end.flatten.compact
        regex_str = aliases.empty? ? '(?!x)x' : aliases.join('|')
        Regexp.new "(?:#{regex_str})"
      end
    end

    # inject a definition into the internal array and set it up for use
    #
    # @param definition [RubyUnits::Unit::Definition]
    def self.use_definition(definition)
      @unit_match_regex = nil # invalidate the unit match regex
      @temp_regex = nil # invalidate the temp regex
      if definition.prefix?
        prefix_values[definition.name] = definition.scalar
        definition.aliases.each { prefix_map[_1] = definition.name }
        @prefix_regex = nil # invalidate the prefix regex
      else
        unit_values[definition.name]          = {}
        unit_values[definition.name][:scalar] = definition.scalar
        unit_values[definition.name][:numerator] = definition.numerator if definition.numerator
        unit_values[definition.name][:denominator] = definition.denominator if definition.denominator
        definition.aliases.each { unit_map[_1] = definition.name }
        @unit_regex = nil # invalidate the unit regex
      end
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

    # Used to copy one unit to another
    # @param from [RubyUnits::Unit] Unit to copy definition from
    # @return [RubyUnits::Unit]
    def copy(from)
      @scalar = from.scalar
      @numerator = from.numerator
      @denominator = from.denominator
      @base = from.base?
      @signature = from.signature
      @base_scalar = from.base_scalar
      @unit_name = from.unit_name
      self
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
    #  {scalar: 1, numerator: 'kg'}
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
      @output      = {}
      raise ArgumentError, 'Invalid Unit Format' if options[0].nil?

      if options.size == 2
        # options[0] is the scalar
        # options[1] is a unit string
        cached = self.class.cached.get(options[1])
        if cached.nil?
          initialize("#{options[0]} #{options[1]}")
        else
          copy(cached * options[0])
        end
        return
      end
      if options.size == 3
        options[1] = options[1].join if options[1].is_a?(Array)
        options[2] = options[2].join if options[2].is_a?(Array)
        cached = self.class.cached.get("#{options[1]}/#{options[2]}")
        if cached.nil?
          initialize("#{options[0]} #{options[1]}/#{options[2]}")
        else
          copy(cached) * options[0]
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
        raise ArgumentError, 'No Unit Specified'
      when String
        parse(options[0])
      else
        raise ArgumentError, 'Invalid Unit Format'
      end
      update_base_scalar
      raise ArgumentError, 'Temperatures must not be less than absolute zero' if temperature? && base_scalar.negative?

      unary_unit = units || ''
      if options.first.instance_of?(String)
        _opt_scalar, opt_units = self.class.parse_into_numbers_and_units(options[0])
        if !(self.class.cached.keys.include?(opt_units) ||
                (opt_units =~ %r{\D/[\d+.]+}) ||
                (opt_units =~ %r{(#{self.class.temp_regex})|(#{STONE_LB_UNIT_REGEX})|(#{LBS_OZ_UNIT_REGEX})|(#{FEET_INCH_UNITS_REGEX})|%|(#{TIME_REGEX})|i\s?(.+)?|&plusmn;|\+/-})) && (opt_units && !opt_units.empty?)
          self.class.cached.set(opt_units, scalar == 1 ? self : opt_units.to_unit)
        end
      end
      unless self.class.cached.keys.include?(unary_unit) || (unary_unit =~ self.class.temp_regex)
        self.class.cached.set(unary_unit, scalar == 1 ? self : unary_unit.to_unit)
      end
      [@scalar, @numerator, @denominator, @base_scalar, @signature, @base].each(&:freeze)
      super()
    end

    # @todo: figure out how to handle :counting units.  This method should probably return :counting instead of :unitless for 'each'
    # return the kind of the unit (:mass, :length, etc...)
    # @return [Symbol]
    def kind
      self.class.kinds[signature]
    end

    # Convert the unit to a Unit, possibly performing a conversion.
    # > The ability to pass a Unit to convert to was added in v3.0.0 for
    # > consistency with other uses of #to_unit.
    #
    # @param other [RubyUnits::Unit, String] unit to convert to
    # @return [RubyUnits::Unit]
    def to_unit(other = nil)
      other ? convert_to(other) : self
    end

    alias unit to_unit

    # Is this unit in base form?
    # @return [Boolean]
    def base?
      return @base if defined? @base

      @base = (@numerator + @denominator)
              .compact
              .uniq
              .map { self.class.definition(_1) }
              .all? { _1.unity? || _1.base? }
      @base
    end

    alias is_base? base?

    # convert to base SI units
    # results of the conversion are cached so subsequent calls to this will be fast
    # @return [Unit]
    # @todo this is brittle as it depends on the display_name of a unit, which can be changed
    def to_base
      return self if base?

      if self.class.unit_map[units] =~ /\A<(?:temp|deg)[CRF]>\Z/
        @signature = self.class.kinds.key(:temperature)
        base = if temperature?
                 convert_to('tempK')
               elsif degree?
                 convert_to('degK')
               end
        return base
      end

      cached_unit = self.class.base_unit_cache.get(units)
      return cached_unit * scalar unless cached_unit.nil?

      num = []
      den = []
      q   = Rational(1)
      @numerator.compact.each do |num_unit|
        if self.class.prefix_values[num_unit]
          q *= self.class.prefix_values[num_unit]
        else
          q *= self.class.unit_values[num_unit][:scalar] if self.class.unit_values[num_unit]
          num << self.class.unit_values[num_unit][:numerator] if self.class.unit_values[num_unit] && self.class.unit_values[num_unit][:numerator]
          den << self.class.unit_values[num_unit][:denominator] if self.class.unit_values[num_unit] && self.class.unit_values[num_unit][:denominator]
        end
      end
      @denominator.compact.each do |num_unit|
        if self.class.prefix_values[num_unit]
          q /= self.class.prefix_values[num_unit]
        else
          q /= self.class.unit_values[num_unit][:scalar] if self.class.unit_values[num_unit]
          den << self.class.unit_values[num_unit][:numerator] if self.class.unit_values[num_unit] && self.class.unit_values[num_unit][:numerator]
          num << self.class.unit_values[num_unit][:denominator] if self.class.unit_values[num_unit] && self.class.unit_values[num_unit][:denominator]
        end
      end

      num = num.flatten.compact
      den = den.flatten.compact
      num = UNITY_ARRAY if num.empty?
      base = self.class.new(self.class.eliminate_terms(q, num, den))
      self.class.base_unit_cache.set(units, base)
      base * @scalar
    end

    alias base to_base

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
    # @note Rational scalars that are equal to an integer will be represented as integers (i.e, 6/1 => 6, 4/2 => 2, etc..)
    # @param [Symbol] target_units
    # @param [Float] precision - the precision to use when converting to a rational
    # @param format [Symbol] Set to :exponential to force all units to be displayed in exponential format
    #
    # @return [String]
    def to_s(target_units = nil, precision: 0.0001, format: RubyUnits.configuration.format)
      out = @output[target_units]
      return out if out

      separator = RubyUnits.configuration.separator
      case target_units
      when :ft
        feet, inches = convert_to('in').scalar.abs.divmod(12)
        improper, frac = inches.divmod(1)
        frac = frac.zero? ? '' : "-#{frac.rationalize(precision)}"
        out = "#{negative? ? '-' : nil}#{feet}'#{improper}#{frac}\""
      when :lbs
        pounds, ounces = convert_to('oz').scalar.abs.divmod(16)
        improper, frac = ounces.divmod(1)
        frac = frac.zero? ? '' : "-#{frac.rationalize(precision)}"
        out  = "#{negative? ? '-' : nil}#{pounds}#{separator}lbs #{improper}#{frac}#{separator}oz"
      when :stone
        stone, pounds = convert_to('lbs').scalar.abs.divmod(14)
        improper, frac = pounds.divmod(1)
        frac = frac.zero? ? '' : "-#{frac.rationalize(precision)}"
        out = "#{negative? ? '-' : nil}#{stone}#{separator}stone #{improper}#{frac}#{separator}lbs"
      when String
        out = case target_units.strip
              when /\A\s*\Z/ # whitespace only
                ''
              when /(%[-+.\w#]+)\s*(.+)*/ # format string like '%0.2f in'
                begin
                  if Regexp.last_match(2) # unit specified, need to convert
                    convert_to(Regexp.last_match(2)).to_s(Regexp.last_match(1), format: format)
                  else
                    "#{Regexp.last_match(1) % @scalar}#{separator}#{Regexp.last_match(2) || units(format: format)}".strip
                  end
                rescue StandardError # parse it like a strftime format string
                  (DateTime.new(0) + self).strftime(target_units)
                end
              when /(\S+)/ # unit only 'mm' or '1/mm'
                convert_to(Regexp.last_match(1)).to_s(format: format)
              else
                raise 'unhandled case'
              end
      else
        out = case @scalar
              when Complex
                "#{@scalar}#{separator}#{units(format: format)}"
              when Rational
                "#{@scalar == @scalar.to_i ? @scalar.to_i : @scalar}#{separator}#{units(format: format)}"
              else
                "#{'%g' % @scalar}#{separator}#{units(format: format)}"
              end.strip
      end
      @output[target_units] = out
      out
    end

    # Normally pretty prints the unit, but if you really want to see the guts of it, pass ':dump'
    # @deprecated
    # @return [String]
    def inspect(dump = nil)
      return super() if dump

      to_s
    end

    # true if unit is a 'temperature', false if a 'degree' or anything else
    # @return [Boolean]
    # @todo use unit definition to determine if it's a temperature instead of a regex
    def temperature?
      degree? && units.match?(self.class.temp_regex)
    end

    alias is_temperature? temperature?

    # true if a degree unit or equivalent.
    # @return [Boolean]
    def degree?
      kind == :temperature
    end

    alias is_degree? degree?

    # returns the 'degree' unit associated with a temperature unit
    # @example '100 tempC'.to_unit.temperature_scale #=> 'degC'
    # @return [String] possible values: degC, degF, degR, or degK
    def temperature_scale
      return nil unless temperature?

      "deg#{self.class.unit_map[units][/temp([CFRK])/, 1]}"
    end

    # returns true if no associated units
    # false, even if the units are "unitless" like 'radians, each, etc'
    # @return [Boolean]
    def unitless?
      @numerator == UNITY_ARRAY && @denominator == UNITY_ARRAY
    end

    # Compare two Unit objects. Throws an exception if they are not of compatible types.
    # Comparisons are done based on the value of the unit in base SI units.
    # @param [Object] other
    # @return [Integer,nil]
    # @raise [NoMethodError] when other does not define <=>
    # @raise [ArgumentError] when units are not compatible
    def <=>(other)
      raise NoMethodError, "undefined method `<=>' for #{base_scalar.inspect}" unless base_scalar.respond_to?(:<=>)

      if other.nil?
        base_scalar <=> nil
      elsif !temperature? && other.respond_to?(:zero?) && other.zero?
        base_scalar <=> 0
      elsif other.instance_of?(Unit)
        raise ArgumentError, "Incompatible Units ('#{units}' not compatible with '#{other.units}')" unless self =~ other

        base_scalar <=> other.base_scalar
      else
        x, y = coerce(other)
        y <=> x
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
      if other.respond_to?(:zero?) && other.zero?
        zero?
      elsif other.instance_of?(Unit)
        return false unless self =~ other

        base_scalar == other.base_scalar
      else
        begin
          x, y = coerce(other)
          x == y
        rescue ArgumentError # return false when object cannot be coerced
          false
        end
      end
    end

    # Check to see if units are compatible, ignoring the scalar part.  This check is done by comparing unit signatures
    # for performance reasons.  If passed a string, this will create a [Unit] object with the string and then do the
    # comparison.
    #
    # @example this permits a syntax like:
    #  unit =~ "mm"
    # @note if you want to do a regexp comparison of the unit string do this ...
    #  unit.units =~ /regexp/
    # @param [Object] other
    # @return [Boolean]
    def =~(other)
      return signature == other.signature if other.is_a?(Unit)

      x, y = coerce(other)
      x =~ y
    rescue ArgumentError # return false when `other` cannot be converted to a [Unit]
      false
    end

    alias compatible? =~
    alias compatible_with? =~

    # Compare two units.  Returns true if quantities and units match
    # @example
    #   RubyUnits::Unit.new("100 cm") === RubyUnits::Unit.new("100 cm")   # => true
    #   RubyUnits::Unit.new("100 cm") === RubyUnits::Unit.new("1 m")      # => false
    # @param [Object] other
    # @return [Boolean]
    def ===(other)
      case other
      when Unit
        (scalar == other.scalar) && (units == other.units)
      else
        begin
          x, y = coerce(other)
          x.same_as?(y)
        rescue ArgumentError
          false
        end
      end
    end

    alias same? ===
    alias same_as? ===

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
        if zero?
          other.dup
        elsif self =~ other
          raise ArgumentError, 'Cannot add two temperatures' if [self, other].all?(&:temperature?)

          if temperature?
            self.class.new(scalar: (scalar + other.convert_to(temperature_scale).scalar), numerator: @numerator, denominator: @denominator, signature: @signature)
          elsif other.temperature?
            self.class.new(scalar: (other.scalar + convert_to(other.temperature_scale).scalar), numerator: other.numerator, denominator: other.denominator, signature: other.signature)
          else
            self.class.new(scalar: (base_scalar + other.base_scalar), numerator: base.numerator, denominator: base.denominator, signature: @signature).convert_to(self)
          end
        else
          raise ArgumentError, "Incompatible Units ('#{self}' not compatible with '#{other}')"
        end
      when Date, Time
        raise ArgumentError, 'Date and Time objects represent fixed points in time and cannot be added to a Unit'
      else
        x, y = coerce(other)
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
        if zero?
          if other.zero?
            other.dup * -1 # preserve Units class
          else
            -other.dup
          end
        elsif self =~ other
          if [self, other].all?(&:temperature?)
            self.class.new(scalar: (base_scalar - other.base_scalar), numerator: KELVIN, denominator: UNITY_ARRAY, signature: @signature).convert_to(temperature_scale)
          elsif temperature?
            self.class.new(scalar: (base_scalar - other.base_scalar), numerator: ['<tempK>'], denominator: UNITY_ARRAY, signature: @signature).convert_to(self)
          elsif other.temperature?
            raise ArgumentError, 'Cannot subtract a temperature from a differential degree unit'
          else
            self.class.new(scalar: (base_scalar - other.base_scalar), numerator: base.numerator, denominator: base.denominator, signature: @signature).convert_to(self)
          end
        else
          raise ArgumentError, "Incompatible Units ('#{self}' not compatible with '#{other}')"
        end
      when Time
        raise ArgumentError, 'Date and Time objects represent fixed points in time and cannot be subtracted from a Unit'
      else
        x, y = coerce(other)
        y - x
      end
    end

    # Multiply two units.
    # @param [Numeric] other
    # @return [Unit]
    # @raise [ArgumentError] when attempting to multiply two temperatures
    def *(other)
      case other
      when Unit
        raise ArgumentError, 'Cannot multiply by temperatures' if [other, self].any?(&:temperature?)

        opts = self.class.eliminate_terms(@scalar * other.scalar, @numerator + other.numerator, @denominator + other.denominator)
        opts[:signature] = @signature + other.signature
        self.class.new(opts)
      when Numeric
        self.class.new(scalar: @scalar * other, numerator: @numerator, denominator: @denominator, signature: @signature)
      else
        x, y = coerce(other)
        x * y
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
        raise ArgumentError, 'Cannot divide with temperatures' if [other, self].any?(&:temperature?)

        sc = Rational(@scalar, other.scalar)
        sc = sc.numerator if sc.denominator == 1
        opts = self.class.eliminate_terms(sc, @numerator + other.denominator, @denominator + other.numerator)
        opts[:signature] = @signature - other.signature
        self.class.new(opts)
      when Numeric
        raise ZeroDivisionError if other.zero?

        sc = Rational(@scalar, other)
        sc = sc.numerator if sc.denominator == 1
        self.class.new(scalar: sc, numerator: @numerator, denominator: @denominator, signature: @signature)
      else
        x, y = coerce(other)
        y / x
      end
    end

    # Returns the remainder when one unit is divided by another
    #
    # @param [Unit] other
    # @return [Unit]
    # @raise [ArgumentError] if units are not compatible
    def remainder(other)
      raise ArgumentError, "Incompatible Units ('#{self}' not compatible with '#{other}')" unless compatible_with?(other)

      self.class.new(base_scalar.remainder(other.to_unit.base_scalar), to_base.units).convert_to(self)
    end

    # Divide two units and return quotient and remainder
    #
    # @param [Unit] other
    # @return [Array(Integer, Unit)]
    # @raise [ArgumentError] if units are not compatible
    def divmod(other)
      raise ArgumentError, "Incompatible Units ('#{self}' not compatible with '#{other}')" unless compatible_with?(other)

      [quo(other).to_base.floor, self % other]
    end

    # Perform a modulo on a unit, will raise an exception if the units are not compatible
    #
    # @param [Unit] other
    # @return [Integer]
    # @raise [ArgumentError] if units are not compatible
    def %(other)
      raise ArgumentError, "Incompatible Units ('#{self}' not compatible with '#{other}')" unless compatible_with?(other)

      self.class.new(base_scalar % other.to_unit.base_scalar, to_base.units).convert_to(self)
    end
    alias modulo %

    # @param [Object] other
    # @return [Unit]
    # @raise [ZeroDivisionError] if other is zero
    def quo(other)
      self / other
    end
    alias fdiv quo

    # Exponentiation.  Only takes integer powers.
    # Note that anything raised to the power of 0 results in a [Unit] object with a scalar of 1, and no units.
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
      raise ArgumentError, 'Cannot raise a temperature to a power' if temperature?

      if other.is_a?(Numeric)
        return inverse if other == -1
        return self if other == 1
        return 1 if other.zero?
      end
      case other
      when Rational
        power(other.numerator).root(other.denominator)
      when Integer
        power(other)
      when Float
        return self**other.to_i if other == other.to_i

        valid = (1..9).map { Rational(1, _1) }
        raise ArgumentError, 'Not a n-th root (1..9), use 1/n' unless valid.include? other.abs

        root(Rational(1, other).to_int)
      when Complex
        raise ArgumentError, 'exponentiation of complex numbers is not supported.'
      else
        raise ArgumentError, 'Invalid Exponent'
      end
    end

    # returns the unit raised to the n-th power
    # @param [Integer] n
    # @return [Unit]
    # @raise [ArgumentError] when attempting to raise a temperature to a power
    # @raise [ArgumentError] when n is not an integer
    def power(n)
      raise ArgumentError, 'Cannot raise a temperature to a power' if temperature?
      raise ArgumentError, 'Exponent must an Integer' unless n.is_a?(Integer)
      return inverse if n == -1
      return 1 if n.zero?
      return self if n == 1
      return (1..(n - 1).to_i).inject(self) { |acc, _elem| acc * self } if n >= 0

      (1..-(n - 1).to_i).inject(self) { |acc, _elem| acc / self }
    end

    # Calculates the n-th root of a unit
    # if n < 0, returns 1/unit^(1/n)
    # @param [Integer] n
    # @return [Unit]
    # @raise [ArgumentError] when attempting to take the root of a temperature
    # @raise [ArgumentError] when n is not an integer
    # @raise [ArgumentError] when n is 0
    def root(n)
      raise ArgumentError, 'Cannot take the root of a temperature' if temperature?
      raise ArgumentError, 'Exponent must an Integer' unless n.is_a?(Integer)
      raise ArgumentError, '0th root undefined' if n.zero?
      return self if n == 1
      return root(n.abs).inverse if n.negative?

      vec = unit_signature_vector
      vec = vec.map { _1 % n }
      raise ArgumentError, 'Illegal root' unless vec.max.zero?

      num = @numerator.dup
      den = @denominator.dup

      @numerator.uniq.each do |item|
        x = num.find_all { _1 == item }.size
        r = ((x / n) * (n - 1)).to_int
        r.times { num.delete_at(num.index(item)) }
      end

      @denominator.uniq.each do |item|
        x = den.find_all { _1 == item }.size
        r = ((x / n) * (n - 1)).to_int
        r.times { den.delete_at(den.index(item)) }
      end
      self.class.new(scalar: @scalar**Rational(1, n), numerator: num, denominator: den)
    end

    # returns inverse of Unit (1/unit)
    # @return [Unit]
    def inverse
      self.class.new('1') / self
    end

    # convert to a specified unit string or to the same units as another Unit
    #
    #  unit.convert_to "kg"   will covert to kilograms
    #  unit1.convert_to unit2 converts to same units as unit2 object
    #
    # To convert a Unit object to match another Unit object, use:
    #  unit1 >>= unit2
    #
    # Special handling for temperature conversions is supported.  If the Unit
    # object is converted from one temperature unit to another, the proper
    # temperature offsets will be used. Supports Kelvin, Celsius, Fahrenheit,
    # and Rankine scales.
    #
    # @note If temperature is part of a compound unit, the temperature will be
    #   treated as a differential and the units will be scaled appropriately.
    # @note When converting units with Integer scalars, the scalar will be
    #   converted to a Rational to avoid unexpected behavior caused by Integer
    #   division.
    # @param other [Unit, String]
    # @return [Unit]
    # @raise [ArgumentError] when attempting to convert a degree to a temperature
    # @raise [ArgumentError] when target unit is unknown
    # @raise [ArgumentError] when target unit is incompatible
    def convert_to(other)
      return self if other.nil?
      return self if other.is_a?(TrueClass)
      return self if other.is_a?(FalseClass)

      if (other.is_a?(Unit) && other.temperature?) || (other.is_a?(String) && other =~ self.class.temp_regex)
        raise ArgumentError, 'Receiver is not a temperature unit' unless degree?

        start_unit = units
        # @type [String]
        target_unit = case other
                      when Unit
                        other.units
                      when String
                        other
                      else
                        raise ArgumentError, 'Unknown target units'
                      end
        return self if target_unit == start_unit

        # @type [Numeric]
        @base_scalar ||= case self.class.unit_map[start_unit]
                         when '<tempC>'
                           @scalar + 273.15
                         when '<tempK>'
                           @scalar
                         when '<tempF>'
                           (@scalar + 459.67).to_r * Rational(5, 9)
                         when '<tempR>'
                           @scalar.to_r * Rational(5, 9)
                         end
        # @type [Numeric]
        q = case self.class.unit_map[target_unit]
            when '<tempC>'
              @base_scalar - 273.15
            when '<tempK>'
              @base_scalar
            when '<tempF>'
              (@base_scalar.to_r * Rational(9, 5)) - 459.67r
            when '<tempR>'
              @base_scalar.to_r * Rational(9, 5)
            end
        self.class.new("#{q} #{target_unit}")
      else
        # @type [Unit]
        target = case other
                 when Unit
                   other
                 when String
                   self.class.new(other)
                 else
                   raise ArgumentError, 'Unknown target units'
                 end
        return self if target.units == units

        raise ArgumentError, "Incompatible Units ('#{self}' not compatible with '#{other}')" unless self =~ target

        numerator1   = @numerator.map { self.class.prefix_values[_1] || _1 }.map { _1.is_a?(Numeric) ? _1 : self.class.unit_values[_1][:scalar] }.compact
        denominator1 = @denominator.map { self.class.prefix_values[_1] || _1 }.map { _1.is_a?(Numeric) ? _1 : self.class.unit_values[_1][:scalar] }.compact
        numerator2   = target.numerator.map { self.class.prefix_values[_1] || _1 }.map { _1.is_a?(Numeric) ? _1 : self.class.unit_values[_1][:scalar] }.compact
        denominator2 = target.denominator.map { self.class.prefix_values[_1] || _1 }.map { _1.is_a?(Numeric) ? _1 : self.class.unit_values[_1][:scalar] }.compact

        # If the scalar is an Integer, convert it to a Rational number so that
        # if the value is scaled during conversion, resolution is not lost due
        # to integer math
        # @type [Rational, Numeric]
        conversion_scalar = @scalar.is_a?(Integer) ? @scalar.to_r : @scalar
        q = conversion_scalar * (numerator1 + denominator2).reduce(1, :*) / (numerator2 + denominator1).reduce(1, :*)
        # Convert the scalar to an Integer if the result is equivalent to an
        # integer
        q = q.to_i if @scalar.is_a?(Integer) && q.to_i == q
        self.class.new(scalar: q, numerator: target.numerator, denominator: target.denominator, signature: target.signature)
      end
    end

    alias >> convert_to
    alias to convert_to

    # converts the unit back to a float if it is unitless.  Otherwise raises an exception
    # @return [Float]
    # @raise [RuntimeError] when not unitless
    def to_f
      return @scalar.to_f if unitless?

      raise "Cannot convert '#{self}' to Float unless unitless.  Use Unit#scalar"
    end

    # converts the unit back to a complex if it is unitless.  Otherwise raises an exception
    # @return [Complex]
    # @raise [RuntimeError] when not unitless
    def to_c
      return Complex(@scalar) if unitless?

      raise "Cannot convert '#{self}' to Complex unless unitless.  Use Unit#scalar"
    end

    # if unitless, returns an int, otherwise raises an error
    # @return [Integer]
    # @raise [RuntimeError] when not unitless
    def to_i
      return @scalar.to_int if unitless?

      raise "Cannot convert '#{self}' to Integer unless unitless.  Use Unit#scalar"
    end

    alias to_int to_i

    # if unitless, returns a Rational, otherwise raises an error
    # @return [Rational]
    # @raise [RuntimeError] when not unitless
    def to_r
      return @scalar.to_r if unitless?

      raise "Cannot convert '#{self}' to Rational unless unitless.  Use Unit#scalar"
    end

    # Returns string formatted for json
    # @return [String]
    def as_json(*)
      to_s
    end

    # Returns the 'unit' part of the Unit object without the scalar
    #
    # @param with_prefix [Boolean] include prefixes in output
    # @param format [Symbol] Set to :exponential to force all units to be displayed in exponential format
    #
    # @return [String]
    def units(with_prefix: true, format: nil)
      return '' if @numerator == UNITY_ARRAY && @denominator == UNITY_ARRAY

      output_numerator   = ['1']
      output_denominator = []
      num                = @numerator.clone.compact
      den                = @denominator.clone.compact

      unless num == UNITY_ARRAY
        definitions = num.map { self.class.definition(_1) }
        definitions.reject!(&:prefix?) unless with_prefix
        definitions = definitions.chunk_while { |definition, _| definition.prefix? }.to_a
        output_numerator = definitions.map { _1.map(&:display_name).join }
      end

      unless den == UNITY_ARRAY
        definitions = den.map { self.class.definition(_1) }
        definitions.reject!(&:prefix?) unless with_prefix
        definitions = definitions.chunk_while { |definition, _| definition.prefix? }.to_a
        output_denominator = definitions.map { _1.map(&:display_name).join }
      end

      on = output_numerator
           .uniq
           .map { [_1, output_numerator.count(_1)] }
           .map { |element, power| (element.to_s.strip + (power > 1 ? "^#{power}" : '')) }

      if format == :exponential
        od = output_denominator
             .uniq
             .map { [_1, output_denominator.count(_1)] }
             .map { |element, power| (element.to_s.strip + (power.positive? ? "^#{-power}" : '')) }
        (on + od).join('*').strip
      else
        od  = output_denominator
              .uniq
              .map { [_1, output_denominator.count(_1)] }
              .map { |element, power| (element.to_s.strip + (power > 1 ? "^#{power}" : '')) }
        "#{on.join('*')}#{od.empty? ? '' : "/#{od.join('*')}"}".strip
      end
    end

    # negates the scalar of the Unit
    # @return [Numeric,Unit]
    def -@
      return -@scalar if unitless?

      dup * -1
    end

    # absolute value of a unit
    # @return [Numeric,Unit]
    def abs
      return @scalar.abs if unitless?

      self.class.new(@scalar.abs, @numerator, @denominator)
    end

    # ceil of a unit
    # @return [Numeric,Unit]
    def ceil(*args)
      return @scalar.ceil(*args) if unitless?

      self.class.new(@scalar.ceil(*args), @numerator, @denominator)
    end

    # @return [Numeric,Unit]
    def floor(*args)
      return @scalar.floor(*args) if unitless?

      self.class.new(@scalar.floor(*args), @numerator, @denominator)
    end

    # Round the unit according to the rules of the scalar's class. Call this
    # with the arguments appropriate for the scalar's class (e.g., Integer,
    # Rational, etc..). Because unit conversions can often result in Rational
    # scalars (to preserve precision), it may be advisable to use +to_s+ to
    # format output instead of using +round+.
    # @example
    #   RubyUnits::Unit.new('21870 mm/min').convert_to('m/min').round(1) #=> 2187/100 m/min
    #   RubyUnits::Unit.new('21870 mm/min').convert_to('m/min').to_s('%0.1f') #=> 21.9 m/min
    #
    # @return [Numeric,Unit]
    def round(*args, **kwargs)
      return @scalar.round(*args, **kwargs) if unitless?

      self.class.new(@scalar.round(*args, **kwargs), @numerator, @denominator)
    end

    # @return [Numeric, Unit]
    def truncate(*args)
      return @scalar.truncate(*args) if unitless?

      self.class.new(@scalar.truncate(*args), @numerator, @denominator)
    end

    # returns next unit in a range.  '1 mm'.to_unit.succ #=> '2 mm'.to_unit
    # only works when the scalar is an integer
    # @return [Unit]
    # @raise [ArgumentError] when scalar is not equal to an integer
    def succ
      raise ArgumentError, 'Non Integer Scalar' unless @scalar == @scalar.to_i

      self.class.new(@scalar.to_i.succ, @numerator, @denominator)
    end

    alias next succ

    # returns previous unit in a range.  '2 mm'.to_unit.pred #=> '1 mm'.to_unit
    # only works when the scalar is an integer
    # @return [Unit]
    # @raise [ArgumentError] when scalar is not equal to an integer
    def pred
      raise ArgumentError, 'Non Integer Scalar' unless @scalar == @scalar.to_i

      self.class.new(@scalar.to_i.pred, @numerator, @denominator)
    end

    # Tries to make a Time object from current unit.  Assumes the current unit hold the duration in seconds from the epoch.
    # @return [Time]
    def to_time
      Time.at(self)
    end

    alias time to_time

    # convert a duration to a DateTime.  This will work so long as the duration is the duration from the zero date
    # defined by DateTime
    # @return [::DateTime]
    def to_datetime
      DateTime.new!(convert_to('d').scalar)
    end

    # @return [Date]
    def to_date
      Date.new0(convert_to('d').scalar)
    end

    # true if scalar is zero
    # @return [Boolean]
    def zero?
      base_scalar.zero?
    end

    # @example '5 min'.to_unit.ago
    # @return [Unit]
    def ago
      before
    end

    # @example '5 min'.before(time)
    # @return [Unit]
    def before(time_point = ::Time.now)
      case time_point
      when Time, Date, DateTime
        (begin
          time_point - self
        rescue StandardError
          time_point.to_datetime - self
        end)
      else
        raise ArgumentError, 'Must specify a Time, Date, or DateTime'
      end
    end

    alias before_now before

    # @example 'min'.since(time)
    # @param [Time, Date, DateTime] time_point
    # @return [Unit]
    # @raise [ArgumentError] when time point is not a Time, Date, or DateTime
    def since(time_point)
      case time_point
      when Time
        self.class.new(::Time.now - time_point, 'second').convert_to(self)
      when DateTime, Date
        self.class.new(::DateTime.now - time_point, 'day').convert_to(self)
      else
        raise ArgumentError, 'Must specify a Time, Date, or DateTime'
      end
    end

    # @example 'min'.until(time)
    # @param [Time, Date, DateTime] time_point
    # @return [Unit]
    def until(time_point)
      case time_point
      when Time
        self.class.new(time_point - ::Time.now, 'second').convert_to(self)
      when DateTime, Date
        self.class.new(time_point - ::DateTime.now, 'day').convert_to(self)
      else
        raise ArgumentError, 'Must specify a Time, Date, or DateTime'
      end
    end

    # @example '5 min'.from(time)
    # @param [Time, Date, DateTime] time_point
    # @return [Time, Date, DateTime]
    # @raise [ArgumentError] when passed argument is not a Time, Date, or DateTime
    def from(time_point)
      case time_point
      when Time, DateTime, Date
        (begin
          time_point + self
        rescue StandardError
          time_point.to_datetime + self
        end)
      else
        raise ArgumentError, 'Must specify a Time, Date, or DateTime'
      end
    end

    alias after from
    alias from_now from

    # Automatically coerce objects to [Unit] when possible. If an object defines a '#to_unit' method, it will be coerced
    # using that method.
    #
    # @param other [Object, #to_unit]
    # @return [Array(Unit, Unit)]
    # @raise [ArgumentError] when `other` cannot be converted to a [Unit]
    def coerce(other)
      return [other.to_unit, self] if other.respond_to?(:to_unit)

      [self.class.new(other), self]
    end

    # Returns a new unit that has been scaled to be more in line with typical usage. This is highly opinionated and not
    # based on any standard. It is intended to be used to make the units more human readable.
    #
    # Some key points:
    # * Units containing 'kg' will be returned as is. The prefix in 'kg' makes this an odd case.
    # * It will use `centi` instead of `milli` when the scalar is between 0.01 and 0.001
    #
    # @return [Unit]
    def best_prefix
      return to_base if scalar.zero?
      return self if units.include?('kg')

      best_prefix = if kind == :information
                      self.class.prefix_values.key(2**((::Math.log(base_scalar, 2) / 10.0).floor * 10))
                    elsif ((1/100r)..(1/10r)).cover?(base_scalar)
                      self.class.prefix_values.key(1/100r)
                    else
                      self.class.prefix_values.key(10**((::Math.log10(base_scalar) / 3.0).floor * 3))
                    end
      to(self.class.new(self.class.prefix_map.key(best_prefix) + units(with_prefix: false)))
    end

    # override hash method so objects with same values are considered equal
    def hash
      [
        @scalar,
        @numerator,
        @denominator,
        @base,
        @signature,
        @base_scalar,
        @unit_name
      ].hash
    end

    # Protected and Private Functions that should only be called from this class
    protected

    # figure out what the scalar part of the base unit for this unit is
    # @return [nil]
    def update_base_scalar
      if base?
        @base_scalar = @scalar
        @signature   = unit_signature
      else
        base         = to_base
        @base_scalar = base.scalar
        @signature   = base.signature
      end
    end

    # calculates the unit signature vector used by unit_signature
    # @return [Array]
    # @raise [ArgumentError] when exponent associated with a unit is > 20 or < -20
    def unit_signature_vector
      return to_base.unit_signature_vector unless base?

      vector = ::Array.new(SIGNATURE_VECTOR.size, 0)
      # it's possible to have a kind that misses the array... kinds like :counting
      # are more like prefixes, so don't use them to calculate the vector
      @numerator.map { self.class.definition(_1) }.each do |definition|
        index = SIGNATURE_VECTOR.index(definition.kind)
        vector[index] += 1 if index
      end
      @denominator.map { self.class.definition(_1) }.each do |definition|
        index = SIGNATURE_VECTOR.index(definition.kind)
        vector[index] -= 1 if index
      end
      raise ArgumentError, 'Power out of range (-20 < net power of a unit < 20)' if vector.any? { _1.abs >= 20 }

      vector
    end

    private

    # used by #dup to duplicate a Unit
    # @param [Unit] other
    # @private
    def initialize_copy(other)
      @numerator   = other.numerator.dup
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
      vector.each_with_index { |item, index| vector[index] = item * (20**index) }
      @signature = vector.inject(0) { |acc, elem| acc + elem }
      @signature
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
    # @return [nil,RubyUnits::Unit]
    # @todo This should either be a separate class or at least a class method
    def parse(passed_unit_string = '0')
      unit_string = passed_unit_string.dup
      unit_string = "#{Regexp.last_match(1)} USD" if unit_string =~ /\$\s*(#{NUMBER_REGEX})/
      unit_string.gsub!("\u00b0".encode('utf-8'), 'deg') if unit_string.encoding == Encoding::UTF_8

      unit_string.gsub!(/(\d)[_,](\d)/, '\1\2') # remove underscores and commas in numbers

      unit_string.gsub!(/[%'"#]/, '%' => 'percent', "'" => 'feet', '"' => 'inch', '#' => 'pound')
      if unit_string.start_with?(COMPLEX_NUMBER)
        match = unit_string.match(COMPLEX_REGEX)
        real = Float(match[:real]) if match[:real]
        imaginary = Float(match[:imaginary])
        unit_s = match[:unit]
        real = real.to_i if real.to_i == real
        imaginary = imaginary.to_i if imaginary.to_i == imaginary
        complex = Complex(real || 0, imaginary)
        complex = complex.to_i if complex.imaginary.zero? && complex.real == complex.real.to_i
        result = self.class.new(unit_s || 1) * complex
        copy(result)
        return
      end

      if unit_string.start_with?(RATIONAL_NUMBER)
        match = unit_string.match(RATIONAL_REGEX)
        numerator = Integer(match[:numerator])
        denominator = Integer(match[:denominator])
        raise ArgumentError, 'Improper fractions must have a whole number part' if !match[:proper].nil? && !match[:proper].match?(/^#{INTEGER_REGEX}$/)

        proper = match[:proper].to_i
        unit_s = match[:unit]
        rational = if proper.negative?
                     (proper - Rational(numerator, denominator))
                   else
                     (proper + Rational(numerator, denominator))
                   end
        rational = rational.to_int if rational.to_int == rational
        result = self.class.new(unit_s || 1) * rational
        copy(result)
        return
      end

      match = unit_string.match(NUMBER_REGEX)
      unit = self.class.cached.get(match[:unit])
      mult = match[:scalar] == '' ? 1.0 : match[:scalar].to_f
      mult = mult.to_int if mult.to_int == mult

      if unit
        copy(unit)
        @scalar      *= mult
        @base_scalar *= mult
        return self
      end

      while unit_string.gsub!(/<(#{self.class.prefix_regex})><(#{self.class.unit_regex})>/, '<\1\2>')
        # replace <prefix><unit> with <prefixunit>
      end
      while unit_string.gsub!(/<#{self.class.unit_match_regex}><#{self.class.unit_match_regex}>/, '<\1\2>*<\3\4>')
        # collapse <prefixunit><prefixunit> into <prefixunit>*<prefixunit>...
      end
      # ... and then strip the remaining brackets for x*y*z
      unit_string.gsub!(/[<>]/, '')

      if (match = unit_string.match(TIME_REGEX))
        hours = match[:hour]
        minutes = match[:min]
        seconds = match[:sec]
        milliseconds = match[:msec]
        raise ArgumentError, 'Invalid Duration' if [hours, minutes, seconds, milliseconds].all?(&:nil?)

        result = self.class.new("#{hours || 0} hours") +
                 self.class.new("#{minutes || 0} minutes") +
                 self.class.new("#{seconds || 0} seconds") +
                 self.class.new("#{milliseconds || 0} milliseconds")
        copy(result)
        return
      end

      # Special processing for unusual unit strings
      # feet -- 6'5"
      if (match = unit_string.match(FEET_INCH_REGEX))
        feet = Integer(match[:feet])
        inches = match[:inches]
        result = if feet.negative?
                   self.class.new("#{feet} ft") - self.class.new("#{inches} inches")
                 else
                   self.class.new("#{feet} ft") + self.class.new("#{inches} inches")
                 end
        copy(result)
        return
      end

      # weight -- 8 lbs 12 oz
      if (match = unit_string.match(LBS_OZ_REGEX))
        pounds = Integer(match[:pounds])
        oz = match[:oz]
        result = if pounds.negative?
                   self.class.new("#{pounds} lbs") - self.class.new("#{oz} oz")
                 else
                   self.class.new("#{pounds} lbs") + self.class.new("#{oz} oz")
                 end
        copy(result)
        return
      end

      # stone -- 3 stone 5, 2 stone, 14 stone 3 pounds, etc.
      if (match = unit_string.match(STONE_LB_REGEX))
        stone = Integer(match[:stone])
        pounds = match[:pounds]
        result = if stone.negative?
                   self.class.new("#{stone} stone") - self.class.new("#{pounds} lbs")
                 else
                   self.class.new("#{stone} stone") + self.class.new("#{pounds} lbs")
                 end
        copy(result)
        return
      end

      # more than one per.  I.e., "1 m/s/s"
      raise(ArgumentError, "'#{passed_unit_string}' Unit not recognized") if unit_string.count('/') > 1
      raise(ArgumentError, "'#{passed_unit_string}' Unit not recognized #{unit_string}") if unit_string =~ /\s[02-9]/

      @scalar, top, bottom = unit_string.scan(UNIT_STRING_REGEX)[0] # parse the string into parts
      top.scan(TOP_REGEX).each do |item|
        n = item[1].to_i
        x = "#{item[0]} "
        if n >= 0
          top.gsub!(/#{item[0]}(\^|\*\*)#{n}/) { x * n }
        elsif n.negative?
          bottom = "#{bottom} #{x * -n}"
          top.gsub!(/#{item[0]}(\^|\*\*)#{n}/, '')
        end
      end
      if bottom
        bottom.gsub!(BOTTOM_REGEX) { "#{Regexp.last_match(1)} " * Regexp.last_match(2).to_i }
        # Separate leading decimal from denominator, if any
        bottom_scalar, bottom = bottom.scan(NUMBER_UNIT_REGEX)[0]
      end

      @scalar = @scalar.to_f unless @scalar.nil? || @scalar.empty?
      @scalar = 1 unless @scalar.is_a? Numeric
      @scalar = @scalar.to_int if @scalar.to_int == @scalar

      bottom_scalar = 1 if bottom_scalar.nil? || bottom_scalar.empty?
      bottom_scalar = if bottom_scalar.to_i == bottom_scalar
                        bottom_scalar.to_i
                      else
                        bottom_scalar.to_f
                      end

      @scalar /= bottom_scalar

      @numerator   ||= UNITY_ARRAY
      @denominator ||= UNITY_ARRAY
      @numerator = top.scan(self.class.unit_match_regex).delete_if(&:empty?).compact if top
      @denominator = bottom.scan(self.class.unit_match_regex).delete_if(&:empty?).compact if bottom

      # eliminate all known terms from this string.  This is a quick check to see if the passed unit
      # contains terms that are not defined.
      used = "#{top} #{bottom}".to_s.gsub(self.class.unit_match_regex, '').gsub(%r{[\d*, "'_^/$]}, '')
      raise(ArgumentError, "'#{passed_unit_string}' Unit not recognized") unless used.empty?

      @numerator = @numerator.map do |item|
        self.class.prefix_map[item[0]] ? [self.class.prefix_map[item[0]], self.class.unit_map[item[1]]] : [self.class.unit_map[item[1]]]
      end.flatten.compact.delete_if(&:empty?)

      @denominator = @denominator.map do |item|
        self.class.prefix_map[item[0]] ? [self.class.prefix_map[item[0]], self.class.unit_map[item[1]]] : [self.class.unit_map[item[1]]]
      end.flatten.compact.delete_if(&:empty?)

      @numerator = UNITY_ARRAY if @numerator.empty?
      @denominator = UNITY_ARRAY if @denominator.empty?
      self
    end
  end
end
