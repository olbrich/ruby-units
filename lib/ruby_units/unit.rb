# frozen_string_literal: true

require "date"
module RubyUnits
  # Copyright 2006-2026
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
      attr_reader :definitions

      # @return [Hash{Symbol => String}] the list of units and their prefixes
      attr_reader :prefix_values

      # @return [Hash{Symbol => String}]
      attr_reader :prefix_map

      # @return [Hash{Symbol => String}]
      attr_reader :unit_map

      # @return [Hash{Symbol => String}]
      attr_reader :unit_values

      # @return [Hash{Integer => Symbol}]
      attr_reader :kinds

      private

      attr_writer :definitions, :prefix_values, :prefix_map, :unit_map, :unit_values
    end
    self.definitions = {}
    self.prefix_values = {}
    self.prefix_map = {}
    self.unit_map = {}
    self.unit_values = {}
    @unit_regex = nil
    @unit_match_regex = nil
    UNITY = "<1>"
    UNITY_ARRAY = [UNITY].freeze

    SIGN_REGEX = /(?:[+-])?/ # +, -, or nothing

    # regex for matching an integer number but not a fraction
    INTEGER_DIGITS_REGEX = %r{(?<!/)\d+(?!/)} # 1, 2, 3, but not 1/2 or -1
    INTEGER_REGEX = /(#{SIGN_REGEX}#{INTEGER_DIGITS_REGEX})/ # -1, 1, +1, but not 1/2
    UNSIGNED_INTEGER_REGEX = /((?<!-)#{INTEGER_DIGITS_REGEX})/ # 1, 2, 3, but not -1
    DIGITS_REGEX = /\d+/ # 0, 1, 2, 3
    DECIMAL_REGEX = /\d*[.]?#{DIGITS_REGEX}/ # 1, 0.1, .1
    # Rational number, including improper fractions: 1 2/3, -1 2/3, 5/3, etc.
    RATIONAL_NUMBER = %r{\(?(?:(?<proper>#{SIGN_REGEX}#{DECIMAL_REGEX})[ -])?(?<numerator>#{SIGN_REGEX}#{DECIMAL_REGEX})/(?<denominator>#{SIGN_REGEX}#{DECIMAL_REGEX})\)?} # 1 2/3, -1 2/3, 5/3, 1-2/3, (1/2) etc.
    # Scientific notation: 1, -1, +1, 1.2, +1.2, -1.2, 123.4E5, +123.4e5,
    #   -123.4E+5, -123.4e-5, etc.
    SCI_NUMBER = /([+-]?\d*[.]?\d+(?:[Ee][+-]?\d+(?![.]))?)/
    # ideally we would like to generate this regex from the alias for a 'feet'
    # and 'inches', but they aren't defined at the point in the code where we
    # need this regex.
    FEET_INCH_UNITS_REGEX = /(?:'|ft|feet)\s*(?<inches>#{RATIONAL_NUMBER}|#{SCI_NUMBER})\s*(?:"|in|inch(?:es)?)/
    FEET_INCH_REGEX = /(?<feet>#{INTEGER_REGEX})\s*#{FEET_INCH_UNITS_REGEX}/
    # ideally we would like to generate this regex from the alias for a 'pound'
    # and 'ounce', but they aren't defined at the point in the code where we
    # need this regex.
    LBS_OZ_UNIT_REGEX = /(?:#|lbs?|pounds?|pound-mass)+[\s,]*(?<oz>#{RATIONAL_NUMBER}|#{UNSIGNED_INTEGER_REGEX})\s*(?:ozs?|ounces?)/
    LBS_OZ_REGEX = /(?<pounds>#{INTEGER_REGEX})\s*#{LBS_OZ_UNIT_REGEX}/
    # ideally we would like to generate this regex from the alias for a 'stone'
    # and 'pound', but they aren't defined at the point in the code where we
    # need this regex. also note that the plural of 'stone' is still 'stone',
    # but we accept 'stones' anyway.
    STONE_LB_UNIT_REGEX = /(?:sts?|stones?)+[\s,]*(?<pounds>#{RATIONAL_NUMBER}|#{UNSIGNED_INTEGER_REGEX})\s*(?:#|lbs?|pounds?|pound-mass)*/
    STONE_LB_REGEX = /(?<stone>#{INTEGER_REGEX})\s*#{STONE_LB_UNIT_REGEX}/
    # Time formats: 12:34:56,78, (hh:mm:ss,msec) etc.
    TIME_REGEX = /(?<hour>\d+):(?<min>\d+):?(?:(?<sec>\d+))?(?:[.](?<msec>\d+))?/
    # Complex numbers: 1+2i, 1.0+2.0i, -1-1i, etc.
    COMPLEX_NUMBER = /(?<real>#{SCI_NUMBER})?(?<imaginary>#{SCI_NUMBER})i\b/
    # Any Complex, Rational, or scientific number
    ANY_NUMBER = /(#{COMPLEX_NUMBER}|#{RATIONAL_NUMBER}|#{SCI_NUMBER})/
    ANY_NUMBER_REGEX = /(?:#{ANY_NUMBER})?\s?([^-\d.].*)?/
    NUMBER_REGEX = /(?<scalar>#{SCI_NUMBER}*)\s*(?<unit>.+)?/ # a number followed by a unit
    UNIT_STRING_REGEX = %r{#{SCI_NUMBER}*\s*([^/]*)/*(.+)*}
    TOP_REGEX = /(?<unit_part>[^ *]+)(?:\^|\*\*)(?<exponent>[\d-]+)/
    BOTTOM_REGEX = /(?<unit_part>[^* ]+)(?:\^|\*\*)(?<exponent>\d+)/
    NUMBER_UNIT_REGEX = /#{SCI_NUMBER}?(.*)/
    COMPLEX_REGEX = /#{COMPLEX_NUMBER}\s?(?<unit>.+)?/
    RATIONAL_REGEX = /#{RATIONAL_NUMBER}\s?(?<unit>.+)?/
    KELVIN = ["<kelvin>"].freeze
    FAHRENHEIT = ["<fahrenheit>"].freeze
    RANKINE = ["<rankine>"].freeze
    CELSIUS = ["<celsius>"].freeze

    # Temperature conversion constants
    CELSIUS_OFFSET_TO_KELVIN = 273.15 # offset to convert Celsius to Kelvin
    FAHRENHEIT_OFFSET_TO_RANKINE = 459.67 # offset to convert Fahrenheit to Rankine
    RATIO_5_9 = Rational(5, 9).freeze # 5/9 ratio for temperature conversions
    RATIO_9_5 = Rational(9, 5).freeze # 9/5 ratio for temperature conversions

    # Valid fractional exponents for root operations (1/1 through 1/9)
    VALID_ROOT_EXPONENTS = (1..9).map { Rational(1, _1) }.freeze

    # Centesimal constants for prefix calculations
    CENTESIMAL_VALUE = Rational(1, 100).freeze # 1/100
    DECILE_VALUE = Rational(1, 10).freeze # 1/10

    # Imperial/US customary unit conversion constants
    INCHES_IN_FOOT = 12
    OUNCES_IN_POUND = 16
    POUNDS_IN_STONE = 14

    @temp_regex = nil
    @special_format_regex = nil
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

    # Use this method to refer to the current class inside instance methods which will facilitate inheritance.
    #
    # @return [Class]
    def unit_class
      @unit_class ||= self.class
    end

    # Callback triggered when a subclass is created. This properly sets up the internal variables, and copies
    # definitions from the parent class.
    #
    # @param [Class] subclass
    def self.inherited(subclass)
      super
      subclass.send(:definitions=, definitions.dup)
      subclass.instance_variable_set(:@kinds, @kinds.dup)
      subclass.setup
    end

    # setup internal arrays and hashes
    # @return [Boolean]
    def self.setup # rubocop:disable Naming/PredicateMethod
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
    # @return [RubyUnits::Unit::Definition]
    # @raise  [ArgumentError] when passed a non-string if using the block form
    # @yield [definition] Optional block to configure the unit definition (only used when unit_definition is a String)
    # @yieldparam definition [RubyUnits::Unit::Definition] the definition being created
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
    def self.define(unit_definition, &)
      if block_given?
        raise ArgumentError, "When using the block form of RubyUnits::Unit.define, pass the name of the unit" unless unit_definition.is_a?(String)

        unit_definition = RubyUnits::Unit::Definition.new(unit_definition, &)
      end
      definitions[unit_definition.name] = unit_definition
      use_definition(unit_definition)
      unit_definition
    end

    # Get the definition for a unit and allow it to be redefined
    #
    # @param [String] name Name of unit to redefine
    # @raise [ArgumentError] if a block is not given
    # @yield [definition] Block to modify the unit definition
    # @yieldparam definition [RubyUnits::Unit::Definition] the definition of the unit being redefined
    # @return (see RubyUnits::Unit.define)
    def self.redefine!(name, &)
      raise ArgumentError, "A block is required to redefine a unit" unless block_given?

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
    def self.clear_cache # rubocop:disable Naming/PredicateMethod
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
      second ? new(first).convert_to(second) : new(first)
    end

    # @param scalar [Numeric] quantity
    # @param numerator_units [Array] numerator
    # @param denominator_units [Array] denominator
    # @return [Hash]
    def self.eliminate_terms(scalar, numerator_units, denominator_units)
      working_numerator = numerator_units.dup
      working_denominator = denominator_units.dup
      working_numerator.delete(UNITY)
      working_denominator.delete(UNITY)

      combined = ::Hash.new(0)

      [[working_numerator, 1], [working_denominator, -1]].each do |array, increment|
        array.chunk_while { |elt_before, _| definition(elt_before).prefix? }
             .to_a
             .each { combined[_1] += increment }
      end

      result_numerator = []
      result_denominator = []
      combined.each do |key, value|
        if value.positive?
          value.times { result_numerator << key }
        elsif value.negative?
          value.abs.times { result_denominator << key }
        end
      end
      result_numerator = UNITY_ARRAY if result_numerator.empty?
      result_denominator = UNITY_ARRAY if result_denominator.empty?

      { scalar:, numerator: result_numerator.flatten, denominator: result_denominator.flatten }
    end

    # Creates a new unit from the current one with all common terms eliminated.
    #
    # @return [RubyUnits::Unit]
    def eliminate_terms
      unit_class.new(unit_class.eliminate_terms(@scalar, @numerator, @denominator))
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
        when NilClass # This happens when no number is passed and we are parsing a pure unit string
          1
        when COMPLEX_NUMBER
          num.to_c
        when RATIONAL_NUMBER
          # We use this method instead of relying on `to_r` because it does not
          # handle improper fractions correctly.
          sign = Regexp.last_match(1) == "-" ? -1 : 1
          whole_part = Regexp.last_match(2).to_i
          fractional_part = Rational(Regexp.last_match(3).to_i, Regexp.last_match(4).to_i)
          sign * (whole_part + fractional_part)
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
      @unit_regex ||= unit_map.keys.sort_by { [_1.length, _1] }.reverse.join("|")
    end

    # return a regex used to match units
    # @return [Regexp]
    def self.unit_match_regex
      @unit_match_regex ||= /(#{prefix_regex})??(#{unit_regex})\b/
    end

    # return a regexp fragment used to match prefixes
    # @return [String]
    def self.prefix_regex
      @prefix_regex ||= prefix_map.keys.sort_by { [_1.length, _1] }.reverse.join("|")
    end

    # Generates (and memoizes) a regexp matching any of the temperature units or their aliases.
    #
    # @return [Regexp]
    def self.temp_regex
      @temp_regex ||= begin
        temp_units = %w[tempK tempC tempF tempR degK degC degF degR]
        aliases = temp_units.filter_map { |unit| definition(unit)&.aliases }.flatten
        regex_str = aliases.empty? ? "(?!x)x" : aliases.join("|")
        Regexp.new "(?:#{regex_str})"
      end
    end

    # Generates (and memoizes) a regexp matching special format units that should not be cached.
    #
    # @return [Regexp]
    def self.special_format_regex
      @special_format_regex ||= Regexp.union(
        %r{\D/[\d+.]+},
        temp_regex,
        STONE_LB_UNIT_REGEX,
        LBS_OZ_UNIT_REGEX,
        FEET_INCH_UNITS_REGEX,
        /%/,
        TIME_REGEX,
        /i\s?(.+)?/,
        %r{&plusmn;|\+/-}
      )
    end

    # inject a definition into the internal array and set it up for use
    #
    # @param definition [RubyUnits::Unit::Definition]
    def self.use_definition(definition)
      invalidate_regex_cache
      if definition.prefix?
        register_prefix_definition(definition)
      else
        register_unit_definition(definition)
      end
    end

    # Invalidate regex cache for unit parsing
    #
    # @return [void]
    def self.invalidate_regex_cache
      @unit_match_regex = nil
      @temp_regex = nil
      @special_format_regex = nil
    end

    # Register a prefix definition
    #
    # @param definition [RubyUnits::Unit::Definition]
    # @return [void]
    def self.register_prefix_definition(definition)
      definition_name = definition.name
      prefix_values[definition_name] = definition.scalar
      register_aliases(definition.aliases, definition_name, prefix_map)
      @prefix_regex = nil
    end

    # Register a unit definition
    #
    # @param definition [RubyUnits::Unit::Definition]
    # @return [void]
    def self.register_unit_definition(definition)
      definition_name = definition.name
      unit_value = create_unit_value(definition)
      unit_values[definition_name] = unit_value
      register_aliases(definition.aliases, definition_name, unit_map)
      @unit_regex = nil
    end

    # Create a hash for unit value
    # @param definition [RubyUnits::Unit::Definition]
    # @return [Hash]
    def self.create_unit_value(definition)
      numerator = definition.numerator
      denominator = definition.denominator
      unit_value = { scalar: definition.scalar }
      unit_value[:numerator] = numerator if numerator
      unit_value[:denominator] = denominator if denominator
      unit_value
    end

    # Register aliases for a definition
    #
    # @param aliases [Array<String>] the aliases to register
    # @param name [String] the canonical name
    # @param map [Hash] the map to register aliases in
    # @return [void]
    def self.register_aliases(aliases, name, map)
      aliases.each { map[_1] = name }
    end

    # Format a fraction part with optional rationalization
    # @param frac [Float] the fractional part
    # @param precision [Float] the precision for rationalization
    # @return [String] the formatted fraction string
    def self.format_fraction(frac, precision: RubyUnits.configuration.default_precision)
      return "" if frac.zero?

      rationalized = frac.rationalize(precision)
      "-#{rationalized}"
    end

    # Helper to simplify a rational by returning numerator if denominator is 1
    # @param [Rational] rational
    # @return [Integer, Rational]
    # @private
    def self.simplify_rational(rational)
      rational.denominator == 1 ? rational.numerator : rational
    end

    include Comparable

    # @return [Numeric]
    attr_reader :scalar

    # @return [Array]
    attr_reader :numerator

    # @return [Array]
    attr_reader :denominator

    # @return [Integer]
    attr_reader :signature

    # @return [Numeric]
    attr_reader :base_scalar

    # @return [Array]
    attr_reader :base_numerator

    # @return [Array]
    attr_reader :base_denominator

    # @return [String]
    attr_reader :output

    # @return [String]
    attr_reader :unit_name

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
      initialize_instance_variables
      parse_array(options)
      finalize_initialization(options)
      super()
    end

    # @todo: figure out how to handle :counting units.  This method should probably return :counting instead of :unitless for 'each'
    # return the kind of the unit (:mass, :length, etc...)
    # @return [Symbol]
    def kind
      unit_class.kinds[signature]
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
              .map { unit_class.definition(_1) }
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

      if unit_class.unit_map[units] =~ /\A<(?:temp|deg)[CRF]>\Z/
        @signature = unit_class.kinds.key(:temperature)
        base = if temperature?
                 convert_to("tempK")
               elsif degree?
                 convert_to("degK")
               end
        return base
      end

      base_cache = unit_class.base_unit_cache
      cached_unit = base_cache.get(units)
      return cached_unit * scalar if cached_unit

      num = []
      den = []
      conversion_factor = Rational(1)
      prefix_vals = unit_class.prefix_values
      unit_vals = unit_class.unit_values

      process_unit_for_numerator = lambda do |num_unit|
        prefix_value = prefix_vals[num_unit]
        if prefix_value
          conversion_factor *= prefix_value
        else
          num_unit_value = unit_vals[num_unit]
          if num_unit_value
            unit_scalar, unit_numerator, unit_denominator = num_unit_value.values_at(:scalar, :numerator, :denominator)
            conversion_factor *= unit_scalar
            num << unit_numerator if unit_numerator
            den << unit_denominator if unit_denominator
          end
        end
      end

      process_unit_for_denominator = lambda do |den_unit|
        prefix_value = prefix_vals[den_unit]
        if prefix_value
          conversion_factor /= prefix_value
        else
          den_unit_value = unit_vals[den_unit]
          if den_unit_value
            unit_scalar, unit_numerator, unit_denominator = den_unit_value.values_at(:scalar, :numerator, :denominator)
            conversion_factor /= unit_scalar
            den << unit_numerator if unit_numerator
            num << unit_denominator if unit_denominator
          end
        end
      end

      @numerator.compact.each(&process_unit_for_numerator)
      @denominator.compact.each(&process_unit_for_denominator)

      num = num.flatten.compact
      den = den.flatten.compact
      num = UNITY_ARRAY if num.empty?
      base = unit_class.new(unit_class.eliminate_terms(conversion_factor, num, den))
      base_cache.set(units, base)
      base * @scalar
    end

    alias base to_base

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
    def to_s(target_units = nil, precision: nil, format: nil)
      configuration = RubyUnits.configuration
      precision ||= configuration.default_precision
      format ||= configuration.format
      out = @output[target_units]
      return out if out

      out = case target_units
            when :ft
              to_feet_inches(precision: precision)
            when :lbs
              to_pounds_ounces(precision: precision)
            when :stone
              to_stone_pounds(precision: precision)
            when String
              convert_string_target(target_units, format)
            else
              format_scalar(units(format: format))
            end

      @output[target_units] = out
      out
    end

    # Pretty prints the unit as a string.
    # To see the internal structure, use the standard Ruby inspect via Kernel#p or similar
    # @return [String]
    def inspect
      to_s
    end

    # true if unit is a 'temperature', false if a 'degree' or anything else
    # @return [Boolean]
    # @todo use unit definition to determine if it's a temperature instead of a regex
    def temperature?
      degree? && units.match?(unit_class.temp_regex)
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

      "deg#{unit_class.unit_map[units][/temp([CFRK])/, 1]}"
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

      if other.is_a?(NilClass)
        base_scalar <=> nil
      elsif !temperature? && other.respond_to?(:zero?) && other.zero?
        base_scalar <=> 0
      elsif other.instance_of?(Unit)
        ensure_compatible_with(other)
        base_scalar <=> other.base_scalar
      else
        coerced_unit, coerced_other = coerce(other)
        coerced_other <=> coerced_unit
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
        return false unless compatible_with?(other)

        base_scalar == other.base_scalar
      else
        begin
          coerced_unit, coerced_other = coerce(other)
          coerced_unit == coerced_other
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

      coerced_unit, coerced_other = coerce(other)
      coerced_unit =~ coerced_other
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
          coerced_unit, coerced_other = coerce(other)
          coerced_unit.same_as?(coerced_other)
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
        elsif compatible_with?(other)
          raise ArgumentError, "Cannot add two temperatures" if [self, other].all?(&:temperature?)

          if temperature?
            unit_class.new(scalar: (scalar + other.convert_to(temperature_scale).scalar), numerator: @numerator, denominator: @denominator, signature: @signature)
          elsif other.temperature?
            unit_class.new(scalar: (other.scalar + convert_to(other.temperature_scale).scalar), numerator: other.numerator, denominator: other.denominator, signature: other.signature)
          else
            unit_class.new(scalar: (base_scalar + other.base_scalar), numerator: base.numerator, denominator: base.denominator, signature: @signature).convert_to(self)
          end
        else
          raise ArgumentError, "Incompatible Units ('#{self}' not compatible with '#{other}')"
        end
      when Date, Time
        raise ArgumentError, "Date and Time objects represent fixed points in time and cannot be added to a Unit"
      else
        coerced_unit, coerced_other = coerce(other)
        coerced_other + coerced_unit
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
          other_copy = other.dup
          if other.zero?
            other_copy * -1 # preserve Units class
          else
            -other_copy
          end
        elsif compatible_with?(other)
          scalar_difference = base_scalar - other.base_scalar
          if [self, other].all?(&:temperature?)
            unit_class.new(scalar: scalar_difference, numerator: KELVIN, denominator: UNITY_ARRAY, signature: @signature).convert_to(temperature_scale)
          elsif temperature?
            unit_class.new(scalar: scalar_difference, numerator: ["<tempK>"], denominator: UNITY_ARRAY, signature: @signature).convert_to(self)
          elsif other.temperature?
            raise ArgumentError, "Cannot subtract a temperature from a differential degree unit"
          else
            unit_class.new(scalar: scalar_difference, numerator: base.numerator, denominator: base.denominator, signature: @signature).convert_to(self)
          end
        else
          raise ArgumentError, "Incompatible Units ('#{self}' not compatible with '#{other}')"
        end
      when Time
        raise ArgumentError, "Date and Time objects represent fixed points in time and cannot be subtracted from a Unit"
      else
        coerced_unit, coerced_other = coerce(other)
        coerced_other - coerced_unit
      end
    end

    # Multiply two units.
    # @param [Numeric] other
    # @return [Unit]
    # @raise [ArgumentError] when attempting to multiply two temperatures
    def *(other)
      case other
      when Unit
        raise ArgumentError, "Cannot multiply by temperatures" if [other, self].any?(&:temperature?)

        opts = unit_class.eliminate_terms(@scalar * other.scalar, @numerator + other.numerator, @denominator + other.denominator)
        opts[:signature] = @signature + other.signature
        unit_class.new(opts)
      when Numeric
        unit_class.new(scalar: @scalar * other, numerator: @numerator, denominator: @denominator, signature: @signature)
      else
        coerced_unit, coerced_other = coerce(other)
        coerced_unit * coerced_other
      end
    end

    # Divide two units.
    # Throws an exception if divisor is 0
    # @param [Numeric] other
    # @return [Unit]
    # @raise [ZeroDivisionError] if divisor is zero
    # @raise [ArgumentError] if attempting to divide a temperature by another temperature
    # :reek:DuplicateMethodCall
    def /(other)
      case other
      when Unit
        raise ArgumentError, "Cannot divide with temperatures" if [other, self].any?(&:temperature?)
        raise ZeroDivisionError if other.zero?

        sc = unit_class.simplify_rational(Rational(@scalar, other.scalar))
        opts = unit_class.eliminate_terms(sc, @numerator + other.denominator, @denominator + other.numerator)
        opts[:signature] = @signature - other.signature
        unit_class.new(opts)
      when Numeric
        raise ZeroDivisionError if other.zero?

        sc = unit_class.simplify_rational(Rational(@scalar, other))
        unit_class.new(scalar: sc, numerator: @numerator, denominator: @denominator, signature: @signature)
      else
        coerced_unit, coerced_other = coerce(other)
        coerced_other / coerced_unit
      end
    end

    # Returns the remainder when one unit is divided by another
    #
    # @param [Unit] other
    # @return [Unit]
    # @raise [ArgumentError] if units are not compatible
    def remainder(other)
      ensure_compatible_with(other)
      unit_class.new(base_scalar.remainder(other.to_unit.base_scalar), to_base.units).convert_to(self)
    end

    # Divide two units and return quotient and remainder
    #
    # @param [Unit] other
    # @return [Array(Integer, Unit)]
    # @raise [ArgumentError] if units are not compatible
    def divmod(other)
      ensure_compatible_with(other)
      [quo(other).to_base.floor, self % other]
    end

    # Perform a modulo on a unit, will raise an exception if the units are not compatible
    #
    # @param [Unit] other
    # @return [Integer]
    # @raise [ArgumentError] if units are not compatible
    def %(other)
      ensure_compatible_with(other)
      unit_class.new(base_scalar % other.to_unit.base_scalar, to_base.units).convert_to(self)
    end
    alias modulo %

    # Divide two units and return quotient as a float or complex.
    # Similar to division but ensures floating point result.
    #
    # @param other [Numeric, Unit]
    # @return [Float, Complex, Unit]
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
      is_temperature = temperature?
      raise ArgumentError, "Cannot raise a temperature to a power" if is_temperature

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
        other_as_int = other.to_i
        return self**other_as_int if other == other_as_int

        raise ArgumentError, "Not a n-th root (1..9), use 1/n" unless VALID_ROOT_EXPONENTS.include? other.abs

        root(Rational(1, other).to_int)
      when Complex
        raise ArgumentError, "exponentiation of complex numbers is not supported."
      else
        raise ArgumentError, "Invalid Exponent"
      end
    end

    # Raise a unit to a power.
    # Returns the unit raised to the n-th power.
    #
    # @param exponent [Integer] the exponent (must be an integer)
    # @return [Unit]
    # @raise [ArgumentError] when attempting to raise a temperature to a power
    # @raise [ArgumentError] when exponent is not an integer
    def power(exponent)
      validate_power_operation(exponent)
      return special_power_case(exponent) if [-1, 0, 1].include?(exponent)

      calculate_power_result(exponent)
    end

    # Calculates the n-th root of a unit
    # Returns the nth root of a unit.
    # If exponent < 0, returns 1/unit^(1/exponent)
    #
    # @param exponent [Integer] the root degree (must be an integer, cannot be 0)
    # @return [Unit]
    # @raise [ArgumentError] when attempting to take the root of a temperature
    # @raise [ArgumentError] when exponent is not an integer
    # @raise [ArgumentError] when exponent is 0
    def root(exponent)
      raise ArgumentError, "Cannot take the root of a temperature" if temperature?
      raise ArgumentError, "Exponent must an Integer" unless exponent.is_a?(Integer)
      raise ArgumentError, "0th root undefined" if exponent.zero?
      return self if exponent == 1
      return root(exponent.abs).inverse if exponent.negative?

      signature_vector = unit_signature_vector
      signature_vector = signature_vector.map { _1 % exponent }
      raise ArgumentError, "Illegal root" unless signature_vector.max.zero?

      result_numerator = @numerator.dup
      result_denominator = @denominator.dup

      items_to_remove_per_unit = exponent - 1
      [[@numerator, result_numerator], [@denominator, result_denominator]].each do |source, result|
        source.uniq.each do |item|
          count = result.count(item)
          count_over_exponent = count / exponent
          removals = (count_over_exponent * items_to_remove_per_unit).to_int
          removals.times { result.delete_at(result.index(item)) }
        end
      end
      unit_class.new(scalar: @scalar**Rational(1, exponent), numerator: result_numerator, denominator: result_denominator)
    end

    # returns inverse of Unit (1/unit)
    # @return [Unit]
    def inverse
      unit_class.new("1") / self
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
      return self if other.is_a?(NilClass)
      return self if other.is_a?(TrueClass)
      return self if other.is_a?(FalseClass)

      if (other.is_a?(Unit) && other.temperature?) || (other.is_a?(String) && other =~ unit_class.temp_regex)
        raise ArgumentError, "Receiver is not a temperature unit" unless degree?

        start_unit = units
        # @type [String]
        target_unit = case other
                      when Unit
                        other.units
                      when String
                        other
                      else
                        raise ArgumentError, "Unknown target units"
                      end
        return self if target_unit == start_unit

        # @type [Numeric]
        unit_map = unit_class.unit_map
        scalar_rational = @scalar.to_r
        @base_scalar ||= case unit_map[start_unit]
                         when "<tempC>"
                           @scalar + CELSIUS_OFFSET_TO_KELVIN
                         when "<tempK>"
                           @scalar
                         when "<tempF>"
                           (@scalar + FAHRENHEIT_OFFSET_TO_RANKINE).to_r * RATIO_5_9
                         when "<tempR>"
                           scalar_rational * RATIO_5_9
                         end
        # @type [Numeric]
        base_scalar_rational = @base_scalar.to_r
        base_times_ratio_nine_fifths = base_scalar_rational * RATIO_9_5
        result_scalar = case unit_map[target_unit]
                        when "<tempC>"
                          @base_scalar - CELSIUS_OFFSET_TO_KELVIN
                        when "<tempK>"
                          @base_scalar
                        when "<tempF>"
                          base_times_ratio_nine_fifths - FAHRENHEIT_OFFSET_TO_RANKINE
                        when "<tempR>"
                          base_times_ratio_nine_fifths
                        end
        unit_class.new("#{result_scalar} #{target_unit}")
      else
        # @type [Unit]
        target = case other
                 when Unit
                   other
                 when String
                   unit_class.new(other)
                 else
                   raise ArgumentError, "Unknown target units"
                 end
        return self if target.units == units

        ensure_compatible_with(target)

        prefix_vals = unit_class.prefix_values
        unit_vals = unit_class.unit_values
        to_scalar = ->(unit_array) { unit_array.map { prefix_vals[_1] || _1 }.map { _1.is_a?(Numeric) ? _1 : unit_vals[_1][:scalar] }.compact }

        target_num = target.numerator
        target_den = target.denominator
        source_numerator_values = to_scalar.call(@numerator)
        source_denominator_values = to_scalar.call(@denominator)
        target_numerator_values = to_scalar.call(target_num)
        target_denominator_values = to_scalar.call(target_den)
        # @type [Rational, Numeric]
        scalar_is_integer = @scalar.is_a?(Integer)
        conversion_scalar = scalar_is_integer ? @scalar.to_r : @scalar
        converted_value = conversion_scalar * (source_numerator_values + target_denominator_values).reduce(1, :*) / (target_numerator_values + source_denominator_values).reduce(1, :*)
        # Convert the scalar to an Integer if the result is equivalent to an
        # integer
        if scalar_is_integer
          converted_as_int = converted_value.to_i
          converted_value = converted_as_int if converted_as_int == converted_value
        end
        unit_class.new(scalar: converted_value, numerator: target_num, denominator: target_den, signature: target.signature)
      end
    end

    alias >> convert_to
    alias to convert_to

    # converts the unit back to a float if it is unitless.  Otherwise raises an exception
    # @return [Float]
    # @raise [RuntimeError] when not unitless
    def to_f
      return_scalar_or_raise(:to_f, Float)
    end

    # converts the unit back to a complex if it is unitless.  Otherwise raises an exception
    # @return [Complex]
    # @raise [RuntimeError] when not unitless
    def to_c
      return_scalar_or_raise(:to_c, Complex)
    end

    # if unitless, returns an int, otherwise raises an error
    # @return [Integer]
    # @raise [RuntimeError] when not unitless
    def to_i
      return_scalar_or_raise(:to_int, Integer)
    end

    alias to_int to_i

    # if unitless, returns a Rational, otherwise raises an error
    # @return [Rational]
    # @raise [RuntimeError] when not unitless
    def to_r
      return_scalar_or_raise(:to_r, Rational)
    end

    # Returns string formatted for json
    # @return [String]
    def as_json(*)
      to_s
    end

    # Returns the 'unit' part of the Unit object without the scalar
    #
    # @param with_prefix [Boolean] include prefixes in output (default: true)
    # @param format [Symbol] Set to :exponential to force exponential notation (e.g., 'm*s^-2'),
    #   or :rational for rational notation (e.g., 'm/s^2'). Defaults to configuration setting.
    # @return [String]
    def units(with_prefix: true, format: nil)
      return "" if @numerator == UNITY_ARRAY && @denominator == UNITY_ARRAY

      output_numerator = ["1"]
      output_denominator = []
      num = @numerator.clone.compact
      den = @denominator.clone.compact

      process_unit_array = lambda do |unit_array|
        definitions = unit_array.map { unit_class.definition(_1) }
        definitions.reject!(&:prefix?) unless with_prefix
        definitions.chunk_while { |definition, _| definition.prefix? }.to_a.map { _1.map(&:display_name).join }
      end

      output_numerator = process_unit_array.call(num) unless num == UNITY_ARRAY
      output_denominator = process_unit_array.call(den) unless den == UNITY_ARRAY

      format_output = lambda do |output_array, exponential_negative = false|
        output_array.uniq.map do |element|
          count = output_array.count(element)
          element_str = element.to_s.strip
          if exponential_negative
            element_str + (count.positive? ? "^#{-count}" : "")
          else
            element_str + (count > 1 ? "^#{count}" : "")
          end
        end
      end

      on = format_output.call(output_numerator)

      if format == :exponential
        od = format_output.call(output_denominator, true)
        (on + od).join("*").strip
      else
        od = format_output.call(output_denominator)
        "#{on.join('*')}#{"/#{od.join('*')}" unless od.empty?}".strip
      end
    end

    # negates the scalar of the Unit
    # @return [Numeric,Unit]
    def -@
      neg_scalar = -@scalar
      return_scalar_or_unit(neg_scalar)
    end

    # absolute value of a unit
    # @return [Numeric,Unit]
    def abs
      abs_scalar = @scalar.abs
      return_scalar_or_unit(abs_scalar)
    end

    # ceil of a unit
    # Forwards all arguments to the scalar's ceil method
    # @return [Numeric,Unit]
    def ceil(...)
      ceiled_scalar = @scalar.ceil(...)
      return_scalar_or_unit(ceiled_scalar)
    end

    # Floor of a unit
    # Forwards all arguments to the scalar's floor method
    # @return [Numeric,Unit]
    def floor(...)
      floored_scalar = @scalar.floor(...)
      return_scalar_or_unit(floored_scalar)
    end

    # Round the unit according to the rules of the scalar's class. Call this
    # with the arguments appropriate for the scalar's class (e.g., Integer,
    # Rational, etc..). Because unit conversions can often result in Rational
    # scalars (to preserve precision), it may be advisable to use +to_s+ to
    # format output instead of using +round+.
    # Forwards all arguments to the scalar's round method
    # @example
    #   RubyUnits::Unit.new('21870 mm/min').convert_to('m/min').round(1) #=> 2187/100 m/min
    #   RubyUnits::Unit.new('21870 mm/min').convert_to('m/min').to_s('%0.1f') #=> 21.9 m/min
    #
    # @return [Numeric,Unit]
    def round(...)
      rounded_scalar = @scalar.round(...)
      return_scalar_or_unit(rounded_scalar)
    end

    # Truncate the unit according to the scalar's truncate method
    # Forwards all arguments to the scalar's truncate method
    # @return [Numeric, Unit]
    def truncate(...)
      truncated_scalar = @scalar.truncate(...)
      return_scalar_or_unit(truncated_scalar)
    end

    # Returns next unit in a range. Increments the scalar by 1.
    # Only works when the scalar is an integer.
    # This is used primarily to make ranges work.
    #
    # @example '1 mm'.to_unit.succ #=> '2 mm'.to_unit
    # @return [Unit]
    # @raise [ArgumentError] when scalar is not equal to an integer
    def succ
      raise ArgumentError, "Non Integer Scalar" unless scalar_is_integer?

      with_new_scalar(@scalar.to_i.succ)
    end

    alias next succ

    # Returns previous unit in a range. Decrements the scalar by 1.
    # Only works when the scalar is an integer.
    # This is used primarily to make ranges work.
    #
    # @example '2 mm'.to_unit.pred #=> '1 mm'.to_unit
    # @return [Unit]
    # @raise [ArgumentError] when scalar is not equal to an integer
    def pred
      raise ArgumentError, "Non Integer Scalar" unless scalar_is_integer?

      with_new_scalar(@scalar.to_i.pred)
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
      DateTime.new!(convert_to("d").scalar)
    end

    # @return [Date]
    def to_date
      Date.new0(convert_to("d").scalar)
    end

    # true if scalar is zero
    # @return [Boolean]
    def zero?
      base_scalar.zero?
    end

    # @example '5 min'.to_unit.ago
    # Returns the time that was this duration ago from now.
    # Alias for #before with default time of Time.now
    #
    # @example '5 min'.to_unit.ago #=> Time 5 minutes ago
    # @return [Time, DateTime]
    def ago
      before
    end

    # Returns the time that was this duration before the given time point.
    #
    # @example '5 min'.to_unit.before(time) #=> Time 5 minutes before time
    # @example '5 min'.to_unit.before #=> Time 5 minutes ago
    # @param time_point [Time, Date, DateTime] the reference time (defaults to Time.now)
    # @return [Time, Date, DateTime]
    # @raise [ArgumentError] when time_point is not a Time, Date, or DateTime
    def before(time_point = ::Time.now)
      validate_time_point(time_point)
      (begin
        time_point - self
      rescue StandardError
        time_point.to_datetime - self
      end)
    end

    alias before_now before

    # @example 'min'.since(time)
    # @param [Time, Date, DateTime] time_point
    # @return [Unit]
    # @raise [ArgumentError] when time point is not a Time, Date, or DateTime
    def since(time_point)
      validate_time_point(time_point)
      case time_point
      when Time
        unit_class.new(::Time.now - time_point, "second").convert_to(self)
      when DateTime, Date
        unit_class.new(::DateTime.now - time_point, "day").convert_to(self)
      end
    end

    # @example 'min'.until(time)
    # @param [Time, Date, DateTime] time_point
    # @return [Unit]
    def until(time_point)
      validate_time_point(time_point)
      case time_point
      when Time
        unit_class.new(time_point - ::Time.now, "second").convert_to(self)
      when DateTime, Date
        unit_class.new(time_point - ::DateTime.now, "day").convert_to(self)
      end
    end

    # @example '5 min'.from(time)
    # @param [Time, Date, DateTime] time_point
    # @return [Time, Date, DateTime]
    # @raise [ArgumentError] when passed argument is not a Time, Date, or DateTime
    def from(time_point)
      validate_time_point(time_point)
      (begin
        time_point + self
      rescue StandardError
        time_point.to_datetime + self
      end)
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

      [unit_class.new(other), self]
    end

    # Returns a new unit that has been scaled to be more in line with typical usage. This is highly opinionated and not
    # based on any standard. It is intended to be used to make the units more human readable.
    #
    # Some key points:
    # * Units containing 'kg' will be returned as is. The prefix in 'kg' makes this an odd case.
    # * It will use `centi` instead of `milli` when the scalar is between 0.01 and 0.001
    #
    # @example
    #   Unit.new('1000 m').best_prefix  #=> '1 km'.to_unit
    #   Unit.new('0.5 m').best_prefix   #=> '50 cm'.to_unit
    #   Unit.new('1500 W').best_prefix  #=> '1.5 kW'.to_unit
    # @return [Unit]
    def best_prefix
      return to_base if scalar.zero?
      return self if units.include?("kg")

      prefix_vals = unit_class.prefix_values
      centesimal_range = CENTESIMAL_VALUE..DECILE_VALUE
      best_prefix = if kind == :information
                      prefix_vals.key(2**((::Math.log(base_scalar, 2) / 10.0).floor * 10))
                    elsif centesimal_range.cover?(base_scalar)
                      prefix_vals.key(CENTESIMAL_VALUE)
                    else
                      prefix_vals.key(10**((::Math.log10(base_scalar) / 3.0).floor * 3))
                    end
      to(unit_class.new(unit_class.prefix_map.key(best_prefix) + units(with_prefix: false)))
    end

    # override hash method so objects with same values are considered equal
    #
    # @return [Integer]
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

    # calculates the unit signature vector used by unit_signature
    # @return [Array]
    # @raise [ArgumentError] when exponent associated with a unit is > 20 or < -20
    def unit_signature_vector
      return to_base.unit_signature_vector unless base?

      vector = ::Array.new(SIGNATURE_VECTOR.size, 0)
      # it's possible to have a kind that misses the array... kinds like :counting
      # are more like prefixes, so don't use them to calculate the vector
      apply_signature_items(vector, @numerator, 1)
      apply_signature_items(vector, @denominator, -1)
      raise ArgumentError, "Power out of range (-20 < net power of a unit < 20)" if vector.any? { _1.abs >= 20 }

      vector
    end

    # Internal helper for unit_signature_vector
    # Applies unit definitions from items to the signature vector with a sign
    # @param vector [Array<Integer>] signature accumulation array
    # @param items [Array<String>] unit tokens (numerator or denominator)
    # @param sign [Integer] +1 for numerator, -1 for denominator
    def apply_signature_items(vector, items, sign)
      items.each do |item|
        definition = unit_class.definition(item)
        index = SIGNATURE_VECTOR.index(definition.kind)
        vector[index] += sign if index
      end
    end

    private

    # figure out what the scalar part of the base unit for this unit is
    # @return [nil]
    def update_base_scalar
      if base?
        @base_scalar = @scalar
        @signature = unit_signature
      else
        base = to_base
        @base_scalar = base.scalar
        @signature = base.signature
      end
    end

    # Ensure that this unit is compatible with another unit
    # @param [Object] other the unit to check compatibility with
    # @return [void]
    # @raise [ArgumentError] if units are not compatible
    def ensure_compatible_with(other)
      raise ArgumentError, "Incompatible Units ('#{self}' not compatible with '#{other}')" unless compatible_with?(other)
    end

    # Validate that a time_point is a Time, Date, or DateTime
    # @param [Object] time_point the object to validate
    # @return [void]
    # @raise [ArgumentError] when time_point is not a Time, Date, or DateTime
    def validate_time_point(time_point)
      raise ArgumentError, "Must specify a Time, Date, or DateTime" unless time_point.is_a?(Time) || time_point.is_a?(Date) || time_point.is_a?(DateTime)
    end

    # Helper methods for power operation

    # Validate that power operation is allowed
    # @param exponent [Numeric] the exponent value
    # @return [void]
    # @raise [ArgumentError] if operation is not allowed (temperature units or non-integer exponent)
    def validate_power_operation(exponent)
      raise ArgumentError, "Cannot raise a temperature to a power" if temperature?
      raise ArgumentError, "Exponent must be an Integer" unless exponent.is_a?(Integer)
    end

    # Handle special cases for power operation
    # @param exponent [Integer] the exponent
    # @return [Unit, Numeric]
    def special_power_case(exponent)
      return inverse if exponent == -1
      return 1 if exponent.zero?

      self
    end

    # Calculate the result of raising to a power
    # @param exponent [Integer] the exponent
    # @return [Unit]
    def calculate_power_result(exponent)
      iterations = (exponent - 1).to_i.abs
      operation = exponent >= 0 ? :* : :/
      (1..iterations).inject(self) { |acc, _elem| acc.send(operation, self) }
    end

    # String formatting helper methods for to_s

    # Format compound units (like feet/inches, lbs/oz, stone/lbs)
    # @param whole [Numeric] the whole part
    # @param part [Numeric] the fractional part
    # @param whole_unit [String] the unit for the whole part
    # @param part_unit [String] the unit for the fractional part
    # @param precision [Float] precision for rationalization
    # @return [String] formatted compound unit string
    def format_compound_unit(whole, part, whole_unit, part_unit, precision: nil)
      configuration = RubyUnits.configuration
      precision ||= configuration.default_precision
      separator = configuration.separator
      improper, frac = part.divmod(1)
      frac_str = unit_class.format_fraction(frac, precision: precision)
      sign = negative? ? "-" : ""
      "#{sign}#{whole}#{separator}#{whole_unit} #{improper}#{frac_str}#{separator}#{part_unit}"
    end

    # Convert to string representation for feet/inches format
    # @param precision [Float] precision for rationalization
    # @return [String] formatted string
    def to_feet_inches(precision: RubyUnits.configuration.default_precision)
      feet, inches = convert_to("in").scalar.abs.divmod(INCHES_IN_FOOT)
      improper, frac = inches.divmod(1)
      frac_str = unit_class.format_fraction(frac, precision: precision)
      sign = negative? ? "-" : ""
      "#{sign}#{feet}'#{improper}#{frac_str}\""
    end

    # Convert to string representation for pounds/ounces format
    # @param precision [Float] precision for rationalization
    # @return [String] formatted string
    def to_pounds_ounces(precision: RubyUnits.configuration.default_precision)
      pounds, ounces = convert_to("oz").scalar.abs.divmod(OUNCES_IN_POUND)
      format_compound_unit(pounds, ounces, "lbs", "oz", precision: precision)
    end

    # Convert to string representation for stone/pounds format
    # @param precision [Float] precision for rationalization
    # @return [String] formatted string
    def to_stone_pounds(precision: RubyUnits.configuration.default_precision)
      stone, pounds = convert_to("lbs").scalar.abs.divmod(POUNDS_IN_STONE)
      format_compound_unit(stone, pounds, "stone", "lbs", precision: precision)
    end

    # Handle string target_units conversion
    # @param target_units [String] the target units string
    # @param format [Symbol] the format to use
    # @return [String] formatted string
    def convert_string_target(target_units, format)
      case target_units.strip
      when /\A\s*\Z/ # whitespace only
        ""
      when /(?<format_str>%[-+.\w#]+)\s*(?<target_unit>.+)*/ # format string like '%0.2f in'
        convert_with_format_string(Regexp.last_match("format_str"), Regexp.last_match("target_unit"), target_units, format)
      when /(?<unit>\S+)/ # unit only 'mm' or '1/mm'
        convert_to(Regexp.last_match("unit")).to_s(format: format)
      else
        raise "unhandled case"
      end
    end

    # Convert with a format string
    # Handles formatting of unit conversions with custom format strings or strftime patterns
    # @param format_str [String] the format string (e.g., '%0.2f')
    # @param target_unit [String, nil] the target unit to convert to, nil for no conversion
    # @param original_target [String] the original target_units string for strftime fallback
    # @param format [Symbol] the output format symbol
    # @return [String] the formatted unit string
    # @raise [StandardError] caught and handled by attempting strftime parsing
    def convert_with_format_string(format_str, target_unit, original_target, format)
      if target_unit # unit specified, need to convert
        convert_to(target_unit).to_s(format_str, format: format)
      else
        separator = RubyUnits.configuration.separator
        "#{format_str % @scalar}#{separator}#{target_unit || units(format: format)}".strip
      end
    rescue StandardError # parse it like a strftime format string
      (DateTime.new(0) + self).strftime(original_target)
    end

    # Format the scalar value with appropriate separator and unit string
    # Handles Complex, Rational, and numeric scalars appropriately
    # @param unit_str [String] the unit string to append
    # @return [String] the formatted scalar with separator and unit string
    def format_scalar(unit_str)
      separator = RubyUnits.configuration.separator
      is_integer = scalar_is_integer?
      case @scalar
      when Complex
        "#{@scalar}#{separator}#{unit_str}"
      when Rational
        "#{is_integer ? @scalar.to_i : @scalar}#{separator}#{unit_str}"
      else
        "#{'%g' % @scalar}#{separator}#{unit_str}"
      end.strip
    end

    # Check if the scalar is effectively an integer
    # Handles Complex numbers by returning false, and compares the scalar to its integer representation
    # @return [Boolean] true if scalar equals its integer representation, false otherwise
    def scalar_is_integer?
      return false if @scalar.is_a?(Complex)

      @scalar == @scalar.to_i
    end

    # Create a new unit with a modified scalar but the same units
    # @param new_scalar [Numeric] the new scalar value for the unit
    # @return [Unit] a new unit with the same numerator and denominator but different scalar
    def with_new_scalar(new_scalar)
      unit_class.new(scalar: new_scalar, numerator: @numerator, denominator: @denominator)
    end

    # Initialize copy: used by #dup to duplicate a Unit
    # Duplicates the numerator and denominator arrays to ensure deep copying
    # @param other [Unit] the unit to copy from
    def initialize_copy(other)
      @numerator = other.numerator.dup
      @denominator = other.denominator.dup
      super
    end

    # Return the scalar if unitless, otherwise raise an error
    # This helper method is used by conversion methods like #to_f, #to_i, #to_c, #to_r
    # @param method [Symbol] the method to call on the scalar (e.g., :to_f, :to_i)
    # @param type [Class] the type being converted to (used in error message)
    # @return [Numeric] the scalar converted using the provided method
    # @raise [RuntimeError] when the unit is not unitless
    def return_scalar_or_raise(method, type)
      raise "Cannot convert '#{self}' to #{type} unless unitless.  Use Unit#scalar" unless unitless?

      @scalar.public_send(method)
    end

    # Return the scalar if unitless, otherwise return a new unit with the modified scalar
    # This helper method is used by unary operations like #-@, #abs, #ceil, #floor, #round, #truncate
    # @param new_scalar [Numeric] the new scalar value
    # @return [Numeric, Unit] the scalar if unitless, or a new unit with the modified scalar
    def return_scalar_or_unit(new_scalar)
      return new_scalar if unitless?

      with_new_scalar(new_scalar)
    end

    # Initialize instance variables to their default values
    # @return [void]
    def initialize_instance_variables
      @scalar = nil
      @base_scalar = nil
      @unit_name = nil
      @signature = nil
      @output = {}
    end

    # Parse options based on the number of arguments
    # @param [Array] options
    # @return [void]
    def parse_array(options)
      case options
      in [first] if first
        parse_single_arg(first)
      in [first, String => second] if first
        parse_two_args(first, second)
      in [first, String | Array => second, String | Array => third] if first
        parse_three_args(first, second, third)
      else
        raise ArgumentError, "Invalid Unit Format"
      end
    end

    # Parse a single argument
    # @param [Unit,Hash,Array,Numeric,Time,Date,DateTime,String] arg
    # @return [void]
    def parse_single_arg(arg)
      case arg
      in Unit => unit
        copy(unit)
      in Hash => hash
        parse_hash(hash)
      in Array => array
        parse_array(array)
      in Numeric => number
        parse_numeric(number)
      in Time => time
        parse_time(time)
      in DateTime | Date => date
        parse_date(date)
      in String => str
        parse_string_arg(str)
      else
        raise ArgumentError, "Invalid Unit Format"
      end
    end

    # Parse and validate a string argument
    # @param [String] str
    # @return [void]
    # @raise [ArgumentError] if string is empty
    def parse_string_arg(str)
      raise ArgumentError, "No Unit Specified" if str.strip.empty?

      parse_string(str)
    end

    # Parse two arguments (scalar and unit string)
    # @param [Numeric] scalar
    # @param [String] unit_string
    # @return [void]
    def parse_two_args(scalar, unit_string)
      cached = unit_class.cached.get(unit_string)
      if cached
        copy(cached * scalar)
      else
        parse_string("#{scalar} #{unit_string}")
      end
    end

    # Parse three arguments (scalar, numerator, denominator)
    # @param [Numeric] scalar
    # @param [String,Array] numerator
    # @param [String,Array] denominator
    # @return [void]
    def parse_three_args(scalar, numerator, denominator)
      unit_str = "#{Array(numerator).join}/#{Array(denominator).join}"

      cached = unit_class.cached.get(unit_str)
      if cached
        copy(cached * scalar)
      else
        parse_string("#{scalar} #{unit_str}")
      end
    end

    # Parse a hash argument
    # WARNING: if you pass a signature, it will be accepted without validation against the units
    # @param [Hash] hash
    # @return [void]
    def parse_hash(hash)
      @scalar = validate_scalar(hash.fetch(:scalar, 1))
      @numerator = validate_unit_array(hash.fetch(:numerator, UNITY_ARRAY), :numerator)
      @denominator = validate_unit_array(hash.fetch(:denominator, UNITY_ARRAY), :denominator)
      @signature = validate_signature(hash[:signature])
    end

    # Validate scalar parameter
    # @param [Object] value
    # @return [Numeric]
    # @raise [ArgumentError] if value is not numeric
    def validate_scalar(value)
      raise ArgumentError, ":scalar must be numeric" unless value.is_a?(Numeric)

      value
    end

    # Validate unit array parameter (numerator or denominator)
    # @param [Object] value
    # @param [Symbol] param_name
    # @return [Array<String>]
    # @raise [ArgumentError] if value is not an array of strings
    def validate_unit_array(value, param_name)
      raise ArgumentError, ":#{param_name} must be an Array<String>" unless value.is_a?(Array) && value.all?(String)

      value
    end

    # Validate signature parameter
    # @param [Object] value
    # @return [Integer, nil]
    # @raise [ArgumentError] if value is not an integer
    def validate_signature(value)
      raise ArgumentError, ":signature must be an Integer" if value && !value.is_a?(Integer)

      value
    end

    # Parse a numeric argument
    # @param [Numeric] num
    # @return [void]
    def parse_numeric(num)
      @scalar = num
      @numerator = @denominator = UNITY_ARRAY
    end

    # Parse a Time argument
    # @param [Time] time
    # @return [void]
    def parse_time(time)
      @scalar = time.to_f
      @numerator = ["<second>"]
      @denominator = UNITY_ARRAY
    end

    # Parse a Date or DateTime argument
    # @param [Date,DateTime] date
    # @return [void]
    def parse_date(date)
      @scalar = date.ajd
      @numerator = ["<day>"]
      @denominator = UNITY_ARRAY
    end

    # Parse a string argument
    # @param [String] str
    # @return [void]
    def parse_string(str)
      parse(str)
    end

    # Finalize initialization by updating base scalar, validating, caching, and freezing
    # @param [Array] options original options passed to initialize
    # @return [void]
    def finalize_initialization(options)
      update_base_scalar
      validate_temperature
      cache_unit_if_needed(options)
      freeze_instance_variables
    end

    # Validate that temperatures are not below absolute zero
    # @return [void]
    # @raise [ArgumentError] if temperature is below absolute zero
    def validate_temperature
      raise ArgumentError, "Temperatures must not be less than absolute zero" if temperature? && base_scalar.negative?
    end

    # Cache the unit if it meets caching criteria
    # @param [Array] options original options passed to initialize
    # @return [void]
    def cache_unit_if_needed(options)
      unary_unit = units || ""

      # Cache units parsed from strings if they meet criteria
      cache_parsed_string_unit(options[0]) if options.first.is_a?(String)

      # Cache unary units if not already cached and not temperature units
      cache_unary_unit(unary_unit)
    end

    # Cache a unit parsed from a string if it meets criteria
    # @param [String] option_string
    # @return [void]
    def cache_parsed_string_unit(option_string)
      _opt_scalar, opt_units = unit_class.parse_into_numbers_and_units(option_string)
      return unless opt_units && !opt_units.empty?

      unit_class.cached.set(opt_units, scalar == 1 ? self : opt_units.to_unit)
    end

    # Cache a unary unit if appropriate
    # @param [String] unary_unit
    # @return [void]
    def cache_unary_unit(unary_unit)
      return if unary_unit == ""

      unit_class.cached.set(unary_unit, scalar == 1 ? self : unary_unit.to_unit)
    end

    # Freeze all instance variables
    # @return [void]
    def freeze_instance_variables
      [@scalar, @numerator, @denominator, @base_scalar, @signature, @base].each(&:freeze)
    end

    # calculates the unit signature id for use in comparing compatible units and simplification
    # the signature is based on a simple classification of units and is based on the following publication
    #
    # Novak, G.S., Jr. "Conversion of units of measurement", IEEE Transactions on Software Engineering, 21(8), Aug 1995, pp.651-661
    # @see http://doi.ieeecomputersociety.org/10.1109/32.403789
    # @return [Array]
    def unit_signature
      return @signature if @signature

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
    def parse(passed_unit_string = "0")
      unit_string = passed_unit_string.dup
      unit_string = "#{Regexp.last_match('usd')} USD" if unit_string =~ /\$\s*(?<usd>#{NUMBER_REGEX})/
      unit_string.gsub!("\u00b0".encode("utf-8"), "deg") if unit_string.encoding == Encoding::UTF_8

      unit_string.gsub!(/(\d)[_,](\d)/, '\1\2') # remove underscores and commas in numbers

      unit_string.gsub!(/[%'"#]/, "%" => "percent", "'" => "feet", '"' => "inch", "#" => "pound")
      if unit_string.start_with?(COMPLEX_NUMBER)
        match = unit_string.match(COMPLEX_REGEX)
        real_str, imaginary_str, unit_s = match.values_at(:real, :imaginary, :unit)
        real = Float(real_str) if real_str
        imaginary = Float(imaginary_str)
        real_as_int = real.to_i if real
        real = real_as_int if real_as_int == real
        imaginary_as_int = imaginary.to_i
        imaginary = imaginary_as_int if imaginary_as_int == imaginary
        complex = Complex(real || 0, imaginary)
        complex_real = complex.real
        complex = complex.to_i if complex.imaginary.zero? && complex_real == complex_real.to_i
        return copy(unit_class.new(unit_s || 1) * complex)
      end

      if unit_string.start_with?(RATIONAL_NUMBER)
        match = unit_string.match(RATIONAL_REGEX)
        numerator_string, denominator_string, proper_string, unit_s = match.values_at(:numerator, :denominator, :proper, :unit)
        numerator = Integer(numerator_string)
        denominator = Integer(denominator_string)
        raise ArgumentError, "Improper fractions must have a whole number part" if proper_string && !proper_string.match?(/^#{INTEGER_REGEX}$/)

        proper = proper_string.to_i
        fraction = Rational(numerator, denominator)
        rational = if proper.negative?
                     (proper - fraction)
                   else
                     (proper + fraction)
                   end
        rational_as_int = rational.to_int
        rational = rational_as_int if rational_as_int == rational
        return copy(unit_class.new(unit_s || 1) * rational)
      end

      match = unit_string.match(NUMBER_REGEX)
      unit_str, scalar_str = match.values_at(:unit, :scalar)
      unit = unit_class.cached.get(unit_str)
      mult = scalar_str == "" ? 1.0 : scalar_str.to_f
      mult_as_int = mult.to_int
      mult = mult_as_int if mult_as_int == mult

      if unit
        copy(unit)
        @scalar *= mult
        @base_scalar *= mult
        return self
      end

      while unit_string.gsub!(/<(#{unit_class.prefix_regex})><(#{unit_class.unit_regex})>/, '<\1\2>')
        # replace <prefix><unit> with <prefixunit>
      end
      unit_match_regex = unit_class.unit_match_regex
      while unit_string.gsub!(/<#{unit_match_regex}><#{unit_match_regex}>/, '<\1\2>*<\3\4>')
        # collapse <prefixunit><prefixunit> into <prefixunit>*<prefixunit>...
      end
      # ... and then strip the remaining brackets for x*y*z
      unit_string.gsub!(/[<>]/, "")

      if (match = unit_string.match(TIME_REGEX))
        hours, minutes, seconds, milliseconds = match.values_at(:hour, :min, :sec, :msec)
        raise ArgumentError, "Invalid Duration" if [hours, minutes, seconds, milliseconds].all?(&:nil?)

        return copy(unit_class.new("#{hours || 0} hours") +
                    unit_class.new("#{minutes || 0} minutes") +
                    unit_class.new("#{seconds || 0} seconds") +
                    unit_class.new("#{milliseconds || 0} milliseconds"))
      end

      # feet -- 6'5"
      if (match = unit_string.match(FEET_INCH_REGEX))
        feet_str, inches = match.values_at(:feet, :inches)
        feet = Integer(feet_str)
        return copy(if feet.negative?
                      unit_class.new("#{feet} ft") - unit_class.new("#{inches} inches")
                    else
                      unit_class.new("#{feet} ft") + unit_class.new("#{inches} inches")
                    end)
      end

      # weight -- 8 lbs 12 oz
      if (match = unit_string.match(LBS_OZ_REGEX))
        pounds_str, oz = match.values_at(:pounds, :oz)
        pounds = Integer(pounds_str)
        return copy(if pounds.negative?
                      unit_class.new("#{pounds} lbs") - unit_class.new("#{oz} oz")
                    else
                      unit_class.new("#{pounds} lbs") + unit_class.new("#{oz} oz")
                    end)
      end

      # stone -- 3 stone 5, 2 stone, 14 stone 3 pounds, etc.
      if (match = unit_string.match(STONE_LB_REGEX))
        stone_str, pounds = match.values_at(:stone, :pounds)
        stone = Integer(stone_str)
        return copy(if stone.negative?
                      unit_class.new("#{stone} stone") - unit_class.new("#{pounds} lbs")
                    else
                      unit_class.new("#{stone} stone") + unit_class.new("#{pounds} lbs")
                    end)
      end

      # more than one per.  I.e., "1 m/s/s"
      validate_unit_string_format(passed_unit_string, unit_string)

      @scalar, top, bottom = unit_string.scan(UNIT_STRING_REGEX)[0] # parse the string into parts
      top.scan(TOP_REGEX).each do |(unit_part, exponent_string)|
        exponent = exponent_string.to_i
        unit_with_space = "#{unit_part} "
        if exponent >= 0
          top.gsub!(/#{unit_part}(\^|\*\*)#{exponent}/) { unit_with_space * exponent }
        elsif exponent.negative?
          bottom = "#{bottom} #{unit_with_space * -exponent}"
          top.gsub!(/#{unit_part}(\^|\*\*)#{exponent}/, "")
        end
      end
      if bottom
        bottom.gsub!(BOTTOM_REGEX) do
          unit_part, bottom_exponent_string = Regexp.last_match.values_at(:unit_part, :exponent)
          "#{unit_part} " * bottom_exponent_string.to_i
        end
        # Separate leading decimal from denominator, if any
        bottom_scalar, bottom = bottom.scan(NUMBER_UNIT_REGEX)[0]
      end

      @scalar = @scalar.to_f unless !@scalar || @scalar.empty?
      @scalar = 1 unless @scalar.is_a? Numeric
      scalar_as_int = @scalar.to_int
      @scalar = scalar_as_int if scalar_as_int == @scalar

      bottom_scalar = 1 if !bottom_scalar || bottom_scalar.empty?
      bottom_scalar_as_int = bottom_scalar.to_i
      bottom_scalar = if bottom_scalar_as_int == bottom_scalar
                        bottom_scalar_as_int
                      else
                        bottom_scalar.to_f
                      end

      @scalar /= bottom_scalar

      @numerator ||= UNITY_ARRAY
      @denominator ||= UNITY_ARRAY
      @numerator = top.scan(unit_match_regex).delete_if(&:empty?).compact if top
      @denominator = bottom.scan(unit_match_regex).delete_if(&:empty?).compact if bottom

      # eliminate all known terms from this string.  This is a quick check to see if the passed unit
      # contains terms that are not defined.
      used = "#{top} #{bottom}".gsub(unit_match_regex, "").gsub(%r{[\d*, "'_^/$]}, "")
      invalid_unit(passed_unit_string) unless used.empty?

      prefix_map = unit_class.prefix_map
      unit_map = unit_class.unit_map
      transform_units = lambda do |(prefix, unit)|
        prefix_value = prefix_map[prefix]
        unit_value = unit_map[unit]
        prefix_value ? [prefix_value, unit_value] : [unit_value]
      end

      @numerator = @numerator.map(&transform_units).flatten.compact.delete_if(&:empty?)

      @denominator = @denominator.map(&transform_units).flatten.compact.delete_if(&:empty?)

      @numerator = UNITY_ARRAY if @numerator.empty?
      @denominator = UNITY_ARRAY if @denominator.empty?
      self
    end

    # Validate the basic format of a parsed unit string.
    # Ensures there is at most one '/' and that there are no stray digits
    # in the unit portion (which indicate malformed input).
    #
    # @param passed_unit_string [String] the original string passed by the caller
    # @param unit_string [String] the normalized unit portion being validated
    # @return [void]
    # @raise [ArgumentError] when the unit string is malformed
    def validate_unit_string_format(passed_unit_string, unit_string)
      slash_count = unit_string.count("/")
      return if slash_count <= 1 && unit_string !~ /\s[02-9]/

      if slash_count > 1
        invalid_unit(passed_unit_string)
      else
        invalid_unit(passed_unit_string, unit_string)
      end
    end

    # Raise a standardized ArgumentError for an unrecognized unit string.
    #
    # @param unit_string [String] the (possibly invalid) unit text
    # @param additional_info [String, nil] optional additional context to include
    # @raise [ArgumentError]
    def invalid_unit(unit_string, additional_info = nil)
      error_msg = "'#{unit_string}' Unit not recognized"
      error_msg += " #{additional_info}" if additional_info
      raise ArgumentError, error_msg
    end
  end
end
