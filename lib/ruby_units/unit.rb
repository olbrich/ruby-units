require 'date'
# Copyright 2006-2015
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
#  RubyUnits::Unit.define("foobar") do |unit|
#    unit.aliases    = %w{foo fb foo-bar}
#    unit.definition = RubyUnits::Unit.new("1 baz")
#  end
#
module RubyUnits
  class Unit < Numeric
    VERSION            = Unit::Version::STRING
    @@definitions      = {}
    @@prefix_values    = {}
    @@prefix_map       = {}
    @@unit_map         = {}
    @@unit_values      = {}
    @@unit_regex       = nil
    @@unit_match_regex = nil
    UNITY              = '<1>'.freeze
    UNITY_ARRAY        = [UNITY].freeze
    # ideally we would like to generate this regex from the alias for a 'feet' and 'inches', but they aren't
    # defined at the point in the code where we need this regex.
    FEET_INCH_UNITS_REGEX = /(?:'|ft|feet)\s*(\d+)\s*(?:"|in|inch(?:es)?)/
    FEET_INCH_REGEX    = /(\d+)\s*#{FEET_INCH_UNITS_REGEX}/
    # ideally we would like to generate this regex from the alias for a 'pound' and 'ounce', but they aren't
    # defined at the point in the code where we need this regex.
    LBS_OZ_UNIT_REGEX  = /(?:#|lbs?|pounds?|pound-mass)+[\s,]*(\d+)\s*(?:ozs?|ounces?)/
    LBS_OZ_REGEX       = /(\d+)\s*#{LBS_OZ_UNIT_REGEX}/
    # ideally we would like to generate this regex from the alias for a 'stone' and 'pound', but they aren't
    # defined at the point in the code where we need this regex.
    # also note that the plural of 'stone' is still 'stone', but we accept 'stones' anyway.
    STONE_LB_UNIT_REGEX = /(?:sts?|stones?)+[\s,]*(\d+)\s*(?:#|lbs?|pounds?|pound-mass)*/
    STONE_LB_REGEX     = /(\d+)\s*#{STONE_LB_UNIT_REGEX}/
    TIME_REGEX         = /(\d+)*:(\d+)*:*(\d+)*[:,]*(\d+)*/
    SCI_NUMBER         = /([+-]?\d*[.]?\d+(?:[Ee][+-]?)?\d*)/
    RATIONAL_NUMBER    = %r{\(?([+-])?(\d+[ -])?(\d+)\/(\d+)\)?}
    COMPLEX_NUMBER     = /#{SCI_NUMBER}?#{SCI_NUMBER}i\b/
    NUMBER_REGEX       = /#{SCI_NUMBER}*\s*(.+)?/
    UNIT_STRING_REGEX  = %r{#{SCI_NUMBER}*\s*([^\/]*)\/*(.+)*}
    TOP_REGEX          = /([^ \*]+)(?:\^|\*\*)([\d-]+)/
    BOTTOM_REGEX       = /([^* ]+)(?:\^|\*\*)(\d+)/
    NUMBER_UNIT_REGEX  = /#{SCI_NUMBER}?(.*)/
    COMPLEX_REGEX      = /#{COMPLEX_NUMBER}\s?(.+)?/
    RATIONAL_REGEX     = /#{RATIONAL_NUMBER}\s?(.+)?/
    KELVIN             = ['<kelvin>'].freeze
    FAHRENHEIT         = ['<fahrenheit>'].freeze
    RANKINE            = ['<rankine>'].freeze
    CELSIUS            = ['<celsius>'].freeze
    @@temp_regex       = nil
    SIGNATURE_VECTOR   = %i[
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
    @@kinds = {
      -312_078     => :elastance,
      -312_058     => :resistance,
      -312_038     => :inductance,
      -152_040     => :magnetism,
      -152_038     => :magnetism,
      -152_058     => :potential,
      -7997        => :specific_volume,
      -79          => :snap,
      -59          => :jolt,
      -39          => :acceleration,
      -38          => :radiation,
      -20          => :frequency,
      -19          => :speed,
      -18          => :viscosity,
      -17          => :volumetric_flow,
      -1           => :wavenumber,
      0            => :unitless,
      1            => :length,
      2            => :area,
      3            => :volume,
      20           => :time,
      400          => :temperature,
      7941         => :yank,
      7942         => :power,
      7959         => :pressure,
      7962         => :energy,
      7979         => :viscosity,
      7961         => :force,
      7981         => :momentum,
      7982         => :angular_momentum,
      7997         => :density,
      7998         => :area_density,
      8000         => :mass,
      152_020      => :radiation_exposure,
      159_999      => :magnetism,
      160_000      => :current,
      160_020      => :charge,
      312_058      => :conductance,
      312_078      => :capacitance,
      3_199_980    => :activity,
      3_199_997    => :molar_concentration,
      3_200_000    => :substance,
      63_999_998   => :illuminance,
      64_000_000   => :luminous_power,
      1_280_000_000 => :currency,
      25_600_000_000  => :information,
      511_999_999_980 => :angular_velocity,
      512_000_000_000 => :angle
    }.freeze
    @@cached_units     = {}
    @@base_unit_cache  = {}

    # Class Methods

    # setup internal arrays and hashes
    # @return [true]
    def self.setup
      clear_cache
      @@prefix_values    = {}
      @@prefix_map       = {}
      @@unit_values      = {}
      @@unit_map         = {}
      @@unit_regex       = nil
      @@unit_match_regex = nil
      @@prefix_regex     = nil

      @@definitions.each do |_name, definition|
        use_definition(definition)
      end

      RubyUnits::Unit.new(1)
      true
    end

    # determine if a unit is already defined
    # @param [String] unit
    # @return [Boolean]
    def self.defined?(unit)
      definitions.values.any? { |d| d.aliases.include?(unit) }
    end

    # return the unit definition for a unit
    # @param [String] unit
    # @return [RubyUnits::Unit::Definition, nil]
    def self.definition(unit_name)
      unit = unit_name =~ /^<.+>$/ ? unit_name : "<#{unit_name}>"
      @@definitions[unit]
    end

    # return a list of all defined units
    # @return [Array]
    def self.definitions
      @@definitions
    end

    # @param  [RubyUnits::Unit::Definition|String] unit_definition
    # @param  [Block] block
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
        raise ArgumentError, 'When using the block form of RubyUnits::Unit.define, pass the name of the unit' unless unit_definition.instance_of?(String)
        unit_definition = RubyUnits::Unit::Definition.new(unit_definition, &block)
      end
      RubyUnits::Unit.definitions[unit_definition.name] = unit_definition
      RubyUnits::Unit.use_definition(unit_definition)
      unit_definition
    end

    # @param [String] name Name of unit to redefine
    # @param [Block] block
    # @raise [ArgumentError] if a block is not given
    # @yield [RubyUnits::Unit::Definition]
    # @return (see RubyUnits::Unit.define)
    # Get the definition for a unit and allow it to be redefined
    def self.redefine!(name)
      raise ArgumentError, 'A block is required to redefine a unit' unless block_given?
      unit_definition = definition(name)
      raise(ArgumentError, "'#{name}' Unit not recognized") unless unit_definition
      yield unit_definition
      @@definitions.delete("<#{name}>")
      define(unit_definition)
      RubyUnits::Unit.setup
    end

    # @param [String] name of unit to undefine
    # @return (see RubyUnits::Unit.setup)
    # Undefine a unit.  Will not raise an exception for unknown units.
    def self.undefine!(unit)
      @@definitions.delete("<#{unit}>")
      RubyUnits::Unit.setup
    end

    # @return [Hash]
    def self.cached
      @@cached_units
    end

    # @return [true]
    def self.clear_cache
      @@cached_units    = {}
      @@base_unit_cache = {}
      RubyUnits::Unit.new(1)
      true
    end

    # @return [Hash]
    def self.base_unit_cache
      @@base_unit_cache
    end

    # @example parse strings
    #   "1 minute in seconds"
    # @param [String] input
    # @return [Unit]
    def self.parse(input)
      first, second = input.scan(/(.+)\s(?:in|to|as)\s(.+)/i).first
      second.nil? ? RubyUnits::Unit.new(first) : RubyUnits::Unit.new(first).convert_to(second)
    end

    # @param [Numeric] q quantity
    # @param [Array] n numerator
    # @param [Array] d denominator
    # @return [Hash]
    def self.eliminate_terms(q, n, d)
      num = n.dup
      den = d.dup

      num.delete_if { |v| v == UNITY }
      den.delete_if { |v| v == UNITY }
      combined = Hash.new(0)

      i = 0
      loop do
        break if i > num.size
        if @@prefix_values.key? num[i]
          k = [num[i], num[i + 1]]
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
        if @@prefix_values.key? den[j]
          k = [den[j], den[j + 1]]
          j += 2
        else
          k = den[j]
          j += 1
        end
        combined[k] -= 1 unless k.nil? || k == UNITY
      end

      num = []
      den = []
      combined.each do |key, value|
        if value >= 0
          value.times { num << key }
        elsif value < 0
          value.abs.times { den << key }
        end
      end
      num = UNITY_ARRAY if num.empty?
      den = UNITY_ARRAY if den.empty?
      { scalar: q, numerator: num.flatten.compact, denominator: den.flatten.compact }
    end

    # return an array of base units
    # @return [Array]
    def self.base_units
      @@base_units ||= @@definitions.dup.delete_if { |_, defn| !defn.base? }.keys.map { |u| RubyUnits::Unit.new(u) }
    end

    # parse a string consisting of a number and a unit string
    # NOTE: This does not properly handle units formatted like '12mg/6ml'
    # @param [String] string
    # @return [Array] consisting of [Numeric, "unit"]
    def self.parse_into_numbers_and_units(string)
      # scientific notation.... 123.234E22, -123.456e-10
      sci       = /[+-]?\d*[.]?\d+(?:[Ee][+-]?)?\d*/
      # rational numbers.... -1/3, 1/5, 20/100, -6 1/2, -6-1/2
      rational  = %r{\(?[+-]?(?:\d+[ -])?\d+\/\d+\)?}
      # complex numbers... -1.2+3i, +1.2-3.3i
      complex   = /#{sci}{2,2}i/
      anynumber = /(?:(#{complex}|#{rational}|#{sci}))?\s?([^-\d\.].*)?/

      num, unit = string.scan(anynumber).first

      [
        case num
        when NilClass
          1
        when complex
          if num.respond_to?(:to_c)
            num.to_c
          else
            #:nocov_19:
            Complex(*num.scan(/(#{sci})(#{sci})i/).flatten.map(&:to_i))
            #:nocov_19:
          end
        when rational
          # if it has whitespace, it will be of the form '6 1/2'
          if num =~ RATIONAL_NUMBER
            sign = Regexp.last_match(1) == '-' ? -1 : 1
            n = Regexp.last_match(2).to_i
            f = Rational(Regexp.last_match(3).to_i, Regexp.last_match(4).to_i)
            sign * (n + f)
          else
            Rational(*num.split('/').map(&:to_i))
          end
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
      @@unit_regex ||= @@unit_map.keys.sort_by { |unit_name| [unit_name.length, unit_name] }.reverse.join('|')
    end

    # return a regex used to match units
    # @return [RegExp]
    def self.unit_match_regex
      @@unit_match_regex ||= /(#{RubyUnits::Unit.prefix_regex})??(#{RubyUnits::Unit.unit_regex})\b/
    end

    # return a regexp fragment used to match prefixes
    # @return [String]
    # @private
    def self.prefix_regex
      @@prefix_regex ||= @@prefix_map.keys.sort_by { |prefix| [prefix.length, prefix] }.reverse.join('|')
    end

    def self.temp_regex
      @@temp_regex ||= begin
        temp_units = %w[tempK tempC tempF tempR degK degC degF degR]
        aliases = temp_units.map do |unit|
          d = RubyUnits::Unit.definition(unit)
          d && d.aliases
        end.flatten.compact
        regex_str = aliases.empty? ? '(?!x)x' : aliases.join('|')
        Regexp.new "(?:#{regex_str})"
      end
    end

    # inject a definition into the internal array and set it up for use
    def self.use_definition(definition)
      @@unit_match_regex = nil # invalidate the unit match regex
      @@temp_regex       = nil # invalidate the temp regex
      if definition.prefix?
        @@prefix_values[definition.name] = definition.scalar
        definition.aliases.each { |alias_name| @@prefix_map[alias_name] = definition.name }
        @@prefix_regex = nil # invalidate the prefix regex
      else
        @@unit_values[definition.name]          = {}
        @@unit_values[definition.name][:scalar] = definition.scalar
        @@unit_values[definition.name][:numerator] = definition.numerator if definition.numerator
        @@unit_values[definition.name][:denominator] = definition.denominator if definition.denominator
        definition.aliases.each { |alias_name| @@unit_map[alias_name] = definition.name }
        @@unit_regex = nil # invalidate the unit regex
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
    # @param [Unit] from Unit to copy definition from
    # @return [Unit]
    def copy(from)
      @scalar      = from.scalar
      @numerator   = from.numerator
      @denominator = from.denominator
      @base = from.base?
      @signature   = from.signature
      @base_scalar = from.base_scalar
      @unit_name = begin
                     from.unit_name
                   rescue
                     nil
                   end
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
        begin
          cached = @@cached_units[options[1]] * options[0]
          copy(cached)
        rescue
          initialize("#{options[0]} #{(begin
                                         options[1].units
                                       rescue
                                         options[1]
                                       end)}")
        end
        return
      end
      if options.size == 3
        options[1] = options[1].join if options[1].is_a?(Array)
        options[2] = options[2].join if options[2].is_a?(Array)
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
        @scalar      = (options[0][:scalar] || 1)
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
      raise ArgumentError, 'Temperatures must not be less than absolute zero' if temperature? && base_scalar < 0
      unary_unit = units || ''
      if options.first.instance_of?(String)
        _opt_scalar, opt_units = RubyUnits::Unit.parse_into_numbers_and_units(options[0])
        unless  @@cached_units.keys.include?(opt_units) ||
                (opt_units =~ %r{\D/[\d+\.]+}) ||
                (opt_units =~ %r{(#{RubyUnits::Unit.temp_regex})|(#{STONE_LB_UNIT_REGEX})|(#{LBS_OZ_UNIT_REGEX})|(#{FEET_INCH_UNITS_REGEX})|%|(#{TIME_REGEX})|i\s?(.+)?|&plusmn;|\+\/-})
          @@cached_units[opt_units] = (scalar == 1 ? self : opt_units.to_unit) if opt_units && !opt_units.empty?
        end
      end
      unless @@cached_units.keys.include?(unary_unit) || (unary_unit =~ /#{RubyUnits::Unit.temp_regex}/)
        @@cached_units[unary_unit] = (scalar == 1 ? self : unary_unit.to_unit)
      end
      [@scalar, @numerator, @denominator, @base_scalar, @signature, @base].each(&:freeze)
      self
    end

    # @todo: figure out how to handle :counting units.  This method should probably return :counting instead of :unitless for 'each'
    # return the kind of the unit (:mass, :length, etc...)
    # @return [Symbol]
    def kind
      @@kinds[signature]
    end

    # @return [Unit]
    def to_unit
      self
    end

    alias unit to_unit

    # Is this unit in base form?
    # @return [Boolean]
    def base?
      return @base if defined? @base
      @base = (@numerator + @denominator)
              .compact
              .uniq
              .map { |unit| RubyUnits::Unit.definition(unit) }
              .all? { |element| element.unity? || element.base? }
      @base
    end

    alias is_base? base?

    # convert to base SI units
    # results of the conversion are cached so subsequent calls to this will be fast
    # @return [Unit]
    # @todo this is brittle as it depends on the display_name of a unit, which can be changed
    def to_base
      return self if base?
      if @@unit_map[units] =~ /\A<(?:temp|deg)[CRF]>\Z/
        @signature = @@kinds.key(:temperature)
        base = if temperature?
                 convert_to('tempK')
               elsif degree?
                 convert_to('degK')
               end
        return base
      end

      cached = (begin
                  (@@base_unit_cache[units] * scalar)
                rescue
                  nil
                end)
      return cached if cached

      num = []
      den = []
      q   = Rational(1)
      @numerator.compact.each do |num_unit|
        if @@prefix_values[num_unit]
          q *= @@prefix_values[num_unit]
        else
          q *= @@unit_values[num_unit][:scalar] if @@unit_values[num_unit]
          num << @@unit_values[num_unit][:numerator] if @@unit_values[num_unit] && @@unit_values[num_unit][:numerator]
          den << @@unit_values[num_unit][:denominator] if @@unit_values[num_unit] && @@unit_values[num_unit][:denominator]
        end
      end
      @denominator.compact.each do |num_unit|
        if @@prefix_values[num_unit]
          q /= @@prefix_values[num_unit]
        else
          q /= @@unit_values[num_unit][:scalar] if @@unit_values[num_unit]
          den << @@unit_values[num_unit][:numerator] if @@unit_values[num_unit] && @@unit_values[num_unit][:numerator]
          num << @@unit_values[num_unit][:denominator] if @@unit_values[num_unit] && @@unit_values[num_unit][:denominator]
        end
      end

      num = num.flatten.compact
      den = den.flatten.compact
      num = UNITY_ARRAY if num.empty?
      base = RubyUnits::Unit.new(RubyUnits::Unit.eliminate_terms(q, num, den))
      @@base_unit_cache[units] = base
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
    # @return [String]
    def to_s(target_units = nil)
      out = @output[target_units]
      return out if out
      separator = RubyUnits.configuration.separator
      case target_units
      when :ft
        inches = convert_to('in').scalar.to_int
        out    = "#{(inches / 12).truncate}\'#{(inches % 12).round}\""
      when :lbs
        ounces = convert_to('oz').scalar.to_int
        out    = "#{(ounces / 16).truncate}#{separator}lbs, #{(ounces % 16).round}#{separator}oz"
      when :stone
        pounds = convert_to('lbs').scalar.to_int
        out = "#{(pounds / 14).truncate}#{separator}stone, #{(pounds % 14).round}#{separator}lb"
      when String
        out = case target_units.strip
              when /\A\s*\Z/ # whitespace only
                ''
              when /(%[\-+\.\w#]+)\s*(.+)*/ # format string like '%0.2f in'
                begin
                  if Regexp.last_match(2) # unit specified, need to convert
                    convert_to(Regexp.last_match(2)).to_s(Regexp.last_match(1))
                  else
                    "#{Regexp.last_match(1) % @scalar}#{separator}#{Regexp.last_match(2) || units}".strip
                  end
                rescue # parse it like a strftime format string
                  (DateTime.new(0) + self).strftime(target_units)
                end
              when /(\S+)/ # unit only 'mm' or '1/mm'
                convert_to(Regexp.last_match(1)).to_s
              else
                raise 'unhandled case'
              end
      else
        out = case @scalar
              when Complex
                "#{@scalar}#{separator}#{units}"
              when Rational
                "#{@scalar == @scalar.to_i ? @scalar.to_i : @scalar}#{separator}#{units}"
              else
                "#{'%g' % @scalar}#{separator}#{units}"
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
      degree? && !(@@unit_map[units] =~ /temp[CFRK]/).nil?
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
      "deg#{@@unit_map[units][/temp([CFRK])/, 1]}"
    end

    # returns true if no associated units
    # false, even if the units are "unitless" like 'radians, each, etc'
    # @return [Boolean]
    def unitless?
      (@numerator == UNITY_ARRAY && @denominator == UNITY_ARRAY)
    end

    # Compare two Unit objects. Throws an exception if they are not of compatible types.
    # Comparisons are done based on the value of the unit in base SI units.
    # @param [Object] other
    # @return [-1|0|1|nil]
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
        signature == other.signature
      else
        begin
          x, y = coerce(other)
          return x =~ y
        rescue ArgumentError
          return false
        end
      end
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
          return x === y
        rescue ArgumentError
          return false
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
          if [self, other].any?(&:temperature?)
            if temperature?
              RubyUnits::Unit.new(scalar: (scalar + other.convert_to(temperature_scale).scalar), numerator: @numerator, denominator: @denominator, signature: @signature)
            else
              RubyUnits::Unit.new(scalar: (other.scalar + convert_to(other.temperature_scale).scalar), numerator: other.numerator, denominator: other.denominator, signature: other.signature)
            end
          else
            RubyUnits::Unit.new(scalar: (base_scalar + other.base_scalar), numerator: base.numerator, denominator: base.denominator, signature: @signature).to(units)
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
            RubyUnits::Unit.new(scalar: (base_scalar - other.base_scalar), numerator: KELVIN, denominator: UNITY_ARRAY, signature: @signature).convert_to(temperature_scale)
          elsif temperature?
            RubyUnits::Unit.new(scalar: (base_scalar - other.base_scalar), numerator: ['<tempK>'], denominator: UNITY_ARRAY, signature: @signature).convert_to(self)
          elsif other.temperature?
            raise ArgumentError, 'Cannot subtract a temperature from a differential degree unit'
          else
            RubyUnits::Unit.new(scalar: (base_scalar - other.base_scalar), numerator: base.numerator, denominator: base.denominator, signature: @signature).to(units)
          end
        else
          raise ArgumentError, "Incompatible Units ('#{self}' not compatible with '#{other}')"
        end
      when Time
        raise ArgumentError, 'Date and Time objects represent fixed points in time and cannot be subtracted from to a Unit, which can only represent time spans'
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
        opts = RubyUnits::Unit.eliminate_terms(@scalar * other.scalar, @numerator + other.numerator, @denominator + other.denominator)
        opts[:signature] = @signature + other.signature
        RubyUnits::Unit.new(opts)
      when Numeric
        RubyUnits::Unit.new(scalar: @scalar * other, numerator: @numerator, denominator: @denominator, signature: @signature)
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
        opts = RubyUnits::Unit.eliminate_terms(sc, @numerator + other.denominator, @denominator + other.numerator)
        opts[:signature] = @signature - other.signature
        RubyUnits::Unit.new(opts)
      when Numeric
        raise ZeroDivisionError if other.zero?
        sc = Rational(@scalar, other)
        sc = sc.numerator if sc.denominator == 1
        RubyUnits::Unit.new(scalar: sc, numerator: @numerator, denominator: @denominator, signature: @signature)
      else
        x, y = coerce(other)
        y / x
      end
    end

    # divide two units and return quotient and remainder
    # when both units are in the same units we just use divmod on the raw scalars
    # otherwise we use the scalar of the base unit which will be a float
    # @param [Object] other
    # @return [Array]
    def divmod(other)
      raise ArgumentError, "Incompatible Units ('#{self}' not compatible with '#{other}')" unless self =~ other
      return scalar.divmod(other.scalar) if units == other.units
      to_base.scalar.divmod(other.to_base.scalar)
    end

    # perform a modulo on a unit, will raise an exception if the units are not compatible
    # @param [Object] other
    # @return [Integer]
    def %(other)
      divmod(other).last
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
      raise ArgumentError, 'Cannot raise a temperature to a power' if temperature?
      if other.is_a?(Numeric)
        return inverse if other == -1
        return self if other == 1
        return 1 if other.zero?
      end
      case other
      when Rational
        return power(other.numerator).root(other.denominator)
      when Integer
        return power(other)
      when Float
        return self**other.to_i if other == other.to_i
        valid = (1..9).map { |n| Rational(1, n) }
        raise ArgumentError, 'Not a n-th root (1..9), use 1/n' unless valid.include? other.abs
        return root(Rational(1, other).to_int)
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
    # @raise [ArgumentError] when attemptint to take the root of a temperature
    # @raise [ArgumentError] when n is not an integer
    # @raise [ArgumentError] when n is 0
    def root(n)
      raise ArgumentError, 'Cannot take the root of a temperature' if temperature?
      raise ArgumentError, 'Exponent must an Integer' unless n.is_a?(Integer)
      raise ArgumentError, '0th root undefined' if n.zero?
      return self if n == 1
      return root(n.abs).inverse if n < 0

      vec = unit_signature_vector
      vec = vec.map { |x| x % n }
      raise ArgumentError, 'Illegal root' unless vec.max.zero?
      num = @numerator.dup
      den = @denominator.dup

      @numerator.uniq.each do |item|
        x = num.find_all { |i| i == item }.size
        r = ((x / n) * (n - 1)).to_int
        r.times { num.delete_at(num.index(item)) }
      end

      @denominator.uniq.each do |item|
        x = den.find_all { |i| i == item }.size
        r = ((x / n) * (n - 1)).to_int
        r.times { den.delete_at(den.index(item)) }
      end
      RubyUnits::Unit.new(scalar: @scalar**Rational(1, n), numerator: num, denominator: den)
    end

    # returns inverse of Unit (1/unit)
    # @return [Unit]
    def inverse
      RubyUnits::Unit.new('1') / self
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
      if (Unit === other && other.temperature?) || (String === other && other =~ /temp[CFRK]/)
        raise ArgumentError, 'Receiver is not a temperature unit' unless degree?
        start_unit = units
        target_unit = begin
                        other.units
                      rescue
                        other
                      end
        @base_scalar ||= case @@unit_map[start_unit]
                         when '<tempC>'
                           @scalar + 273.15
                         when '<tempK>'
                           @scalar
                         when '<tempF>'
                           (@scalar + 459.67).to_r * Rational(5, 9)
                         when '<tempR>'
                           @scalar.to_r * Rational(5, 9)
                         end
        q = case @@unit_map[target_unit]
            when '<tempC>'
              @base_scalar - 273.15r
            when '<tempK>'
              @base_scalar
            when '<tempF>'
              @base_scalar.to_r * Rational(9, 5) - 459.67r
            when '<tempR>'
              @base_scalar.to_r * Rational(9, 5)
            end
        return RubyUnits::Unit.new("#{q} #{target_unit}")
      else
        case other
        when Unit
          return self if other.units == units
          target = other
        when String
          target = RubyUnits::Unit.new(other)
        else
          raise ArgumentError, 'Unknown target units'
        end
        raise ArgumentError, "Incompatible Units ('#{self}' not compatible with '#{other}')" unless self =~ target
        numerator1   = @numerator.map { |x| @@prefix_values[x] ? @@prefix_values[x] : x }.map { |i| i.is_a?(Numeric) ? i : @@unit_values[i][:scalar] }.compact
        denominator1 = @denominator.map { |x| @@prefix_values[x] ? @@prefix_values[x] : x }.map { |i| i.is_a?(Numeric) ? i : @@unit_values[i][:scalar] }.compact
        numerator2   = target.numerator.map { |x| @@prefix_values[x] ? @@prefix_values[x] : x }.map { |x| x.is_a?(Numeric) ? x : @@unit_values[x][:scalar] }.compact
        denominator2 = target.denominator.map { |x| @@prefix_values[x] ? @@prefix_values[x] : x }.map { |x| x.is_a?(Numeric) ? x : @@unit_values[x][:scalar] }.compact

        q = @scalar * ((numerator1 + denominator2).inject(1) { |acc, elem| acc * elem }) /
            ((numerator2 + denominator1).inject(1) { |acc, elem| acc * elem })
        return RubyUnits::Unit.new(scalar: q, numerator: target.numerator, denominator: target.denominator, signature: target.signature)
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

    # returns the 'unit' part of the Unit object without the scalar
    # @return [String]
    def units(with_prefix: true)
      return '' if @numerator == UNITY_ARRAY && @denominator == UNITY_ARRAY
      output_numerator   = ['1']
      output_denominator = []
      num                = @numerator.clone.compact
      den                = @denominator.clone.compact

      unless num == UNITY_ARRAY
        definitions = num.map { |element| RubyUnits::Unit.definition(element) }
        definitions.reject!(&:prefix?) unless with_prefix
        # there is a bug in jruby 9.1.6.0's implementation of chunk_while
        # see https://github.com/jruby/jruby/issues/4410
        # TODO: fix this after jruby fixes their bug.
        definitions = if definitions.respond_to?(:chunk_while) && RUBY_ENGINE != 'jruby'
                        definitions.chunk_while { |defn, _| defn.prefix? }.to_a
                      else # chunk_while is new to ruby 2.3+, so fallback to less efficient methods for older ruby
                        result = []
                        enumerator = definitions.to_enum
                        loop do
                          first = enumerator.next
                          result << (first.prefix? ? [first, enumerator.next] : [first])
                        end
                        result
                      end
        output_numerator = definitions.map { |element| element.map(&:display_name).join }
      end

      unless den == UNITY_ARRAY
        definitions = den.map { |element| RubyUnits::Unit.definition(element) }
        definitions.reject!(&:prefix?) unless with_prefix
        # there is a bug in jruby 9.1.6.0's implementation of chunk_while
        # see https://github.com/jruby/jruby/issues/4410
        # TODO: fix this after jruby fixes their bug.
        definitions = if definitions.respond_to?(:chunk_while) && RUBY_ENGINE != 'jruby'
                        definitions.chunk_while { |defn, _| defn.prefix? }.to_a
                      else # chunk_while is new to ruby 2.3+, so fallback to less efficient methods for older ruby
                        result = []
                        enumerator = definitions.to_enum
                        loop do
                          first = enumerator.next
                          result << (first.prefix? ? [first, enumerator.next] : [first])
                        end
                        result
                      end
        output_denominator = definitions.map { |element| element.map(&:display_name).join }
      end

      on  = output_numerator
            .uniq
            .map { |x| [x, output_numerator.count(x)] }
            .map { |element, power| (element.to_s.strip + (power > 1 ? "^#{power}" : '')) }
      od  = output_denominator
            .uniq
            .map { |x| [x, output_denominator.count(x)] }
            .map { |element, power| (element.to_s.strip + (power > 1 ? "^#{power}" : '')) }
      "#{on.join('*')}#{od.empty? ? '' : '/' + od.join('*')}".strip
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
      RubyUnits::Unit.new(@scalar.abs, @numerator, @denominator)
    end

    # ceil of a unit
    # @return [Numeric,Unit]
    def ceil
      return @scalar.ceil if unitless?
      RubyUnits::Unit.new(@scalar.ceil, @numerator, @denominator)
    end

    # @return [Numeric,Unit]
    def floor
      return @scalar.floor if unitless?
      RubyUnits::Unit.new(@scalar.floor, @numerator, @denominator)
    end

    # @return [Numeric,Unit]
    def round(ndigits = 0)
      return @scalar.round(ndigits) if unitless?
      RubyUnits::Unit.new(@scalar.round(ndigits), @numerator, @denominator)
    end

    # @return [Numeric, Unit]
    def truncate
      return @scalar.truncate if unitless?
      RubyUnits::Unit.new(@scalar.truncate, @numerator, @denominator)
    end

    # returns next unit in a range.  '1 mm'.to_unit.succ #=> '2 mm'.to_unit
    # only works when the scalar is an integer
    # @return [Unit]
    # @raise [ArgumentError] when scalar is not equal to an integer
    def succ
      raise ArgumentError, 'Non Integer Scalar' unless @scalar == @scalar.to_i
      RubyUnits::Unit.new(@scalar.to_i.succ, @numerator, @denominator)
    end

    alias next succ

    # returns previous unit in a range.  '2 mm'.to_unit.pred #=> '1 mm'.to_unit
    # only works when the scalar is an integer
    # @return [Unit]
    # @raise [ArgumentError] when scalar is not equal to an integer
    def pred
      raise ArgumentError, 'Non Integer Scalar' unless @scalar == @scalar.to_i
      RubyUnits::Unit.new(@scalar.to_i.pred, @numerator, @denominator)
    end

    # Tries to make a Time object from current unit.  Assumes the current unit hold the duration in seconds from the epoch.
    # @return [Time]
    def to_time
      Time.at(self)
    end

    alias time to_time

    # convert a duration to a DateTime.  This will work so long as the duration is the duration from the zero date
    # defined by DateTime
    # @return [DateTime]
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
        return (begin
                  time_point - self
                rescue
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
        (Time.now - time_point).to_unit('s').convert_to(self)
      when DateTime, Date
        (DateTime.now - time_point).to_unit('d').convert_to(self)
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
        (time_point - Time.now).to_unit('s').convert_to(self)
      when DateTime, Date
        (time_point - DateTime.now).to_unit('d').convert_to(self)
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
         rescue
           time_point.to_datetime + self
         end)
      else
        raise ArgumentError, 'Must specify a Time, Date, or DateTime'
      end
    end

    alias after from
    alias from_now from

    # automatically coerce objects to units when possible
    # if an object defines a 'to_unit' method, it will be coerced using that method
    # @param [Object, #to_unit]
    # @return [Array]
    def coerce(other)
      return [other.to_unit, self] if other.respond_to? :to_unit
      case other
      when Unit
        [other, self]
      else
        [RubyUnits::Unit.new(other), self]
      end
    end

    # returns a new unit that has been scaled to be more in line with typical usage.
    def best_prefix
      return to_base if scalar.zero?
      best_prefix = if kind == :information
                      @@prefix_values.key(2**((Math.log(base_scalar, 2) / 10.0).floor * 10))
                    else
                      @@prefix_values.key(10**((Math.log10(base_scalar) / 3.0).floor * 3))
                    end
      to(RubyUnits::Unit.new(@@prefix_map.key(best_prefix) + units(with_prefix: false)))
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
      vector = Array.new(SIGNATURE_VECTOR.size, 0)
      # it's possible to have a kind that misses the array... kinds like :counting
      # are more like prefixes, so don't use them to calculate the vector
      @numerator.map { |element| RubyUnits::Unit.definition(element) }.each do |definition|
        index = SIGNATURE_VECTOR.index(definition.kind)
        vector[index] += 1 if index
      end
      @denominator.map { |element| RubyUnits::Unit.definition(element) }.each do |definition|
        index = SIGNATURE_VECTOR.index(definition.kind)
        vector[index] -= 1 if index
      end
      raise ArgumentError, 'Power out of range (-20 < net power of a unit < 20)' if vector.any? { |x| x.abs >= 20 }
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
      vector.each_with_index { |item, index| vector[index] = item * 20**index }
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
    # @return [nil | Unit]
    # @todo This should either be a separate class or at least a class method
    def parse(passed_unit_string = '0')
      unit_string = passed_unit_string.dup
      unit_string = "#{Regexp.last_match(1)} USD" if unit_string =~ /\$\s*(#{NUMBER_REGEX})/
      unit_string.gsub!("\u00b0".force_encoding('utf-8'), 'deg') if unit_string.encoding == Encoding::UTF_8

      unit_string.gsub!(/[%'"#]/, '%' => 'percent', "'" => 'feet', '"' => 'inch', '#' => 'pound')

      if defined?(Complex) && unit_string =~ COMPLEX_NUMBER
        real, imaginary, unit_s = unit_string.scan(COMPLEX_REGEX)[0]
        result                  = RubyUnits::Unit.new(unit_s || '1') * Complex(real.to_f, imaginary.to_f)
        copy(result)
        return
      end

      if defined?(Rational) && unit_string =~ RATIONAL_NUMBER
        sign, proper, numerator, denominator, unit_s = unit_string.scan(RATIONAL_REGEX)[0]
        sign = sign == '-' ? -1 : 1
        rational = sign * (proper.to_i + Rational(numerator.to_i, denominator.to_i))
        result = RubyUnits::Unit.new(unit_s || '1') * rational
        copy(result)
        return
      end

      unit_string =~ NUMBER_REGEX
      unit = @@cached_units[Regexp.last_match(2)]
      mult = begin
               (Regexp.last_match(1).empty? ? 1.0 : Regexp.last_match(1).to_f)
             rescue
               1.0
             end
      mult = mult.to_int if mult.to_int == mult
      if unit
        copy(unit)
        @scalar      *= mult
        @base_scalar *= mult
        return self
      end

      while unit_string.gsub!(/(<#{@@unit_regex})><(#{@@unit_regex}>)/, '\1*\2')
        # collapse <x><y><z> into <x*y*z>...
      end
      # ... and then strip the remaining brackets for x*y*z
      unit_string.gsub!(/[<>]/, '')

      if unit_string =~ /:/
        hours, minutes, seconds, microseconds = unit_string.scan(TIME_REGEX)[0]
        raise ArgumentError, 'Invalid Duration' if [hours, minutes, seconds, microseconds].all?(&:nil?)
        result = RubyUnits::Unit.new("#{hours || 0} h") +
                 RubyUnits::Unit.new("#{minutes || 0} minutes") +
                 RubyUnits::Unit.new("#{seconds || 0} seconds") +
                 RubyUnits::Unit.new("#{microseconds || 0} usec")
        copy(result)
        return
      end

      # Special processing for unusual unit strings
      # feet -- 6'5"
      feet, inches = unit_string.scan(FEET_INCH_REGEX)[0]
      if feet && inches
        result = RubyUnits::Unit.new("#{feet} ft") + RubyUnits::Unit.new("#{inches} inches")
        copy(result)
        return
      end

      # weight -- 8 lbs 12 oz
      pounds, oz = unit_string.scan(LBS_OZ_REGEX)[0]
      if pounds && oz
        result = RubyUnits::Unit.new("#{pounds} lbs") + RubyUnits::Unit.new("#{oz} oz")
        copy(result)
        return
      end

      # stone -- 3 stone 5, 2 stone, 14 stone 3 pounds, etc.
      stone, pounds = unit_string.scan(STONE_LB_REGEX)[0]
      if stone && pounds
        result = RubyUnits::Unit.new("#{stone} stone") + RubyUnits::Unit.new("#{pounds} lbs")
        copy(result)
        return
      end

      # more than one per.  I.e., "1 m/s/s"
      raise(ArgumentError, "'#{passed_unit_string}' Unit not recognized") if unit_string.count('/') > 1
      raise(ArgumentError, "'#{passed_unit_string}' Unit not recognized") if unit_string =~ /\s[02-9]/
      @scalar, top, bottom = unit_string.scan(UNIT_STRING_REGEX)[0] # parse the string into parts
      top.scan(TOP_REGEX).each do |item|
        n = item[1].to_i
        x = "#{item[0]} "
        if n >= 0
          top.gsub!(/#{item[0]}(\^|\*\*)#{n}/) { x * n }
        elsif n < 0
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
      @numerator = top.scan(RubyUnits::Unit.unit_match_regex).delete_if(&:empty?).compact if top
      @denominator = bottom.scan(RubyUnits::Unit.unit_match_regex).delete_if(&:empty?).compact if bottom

      # eliminate all known terms from this string.  This is a quick check to see if the passed unit
      # contains terms that are not defined.
      used = "#{top} #{bottom}".to_s.gsub(RubyUnits::Unit.unit_match_regex, '').gsub(%r{[\d\*, "'_^\/\$]}, '')
      raise(ArgumentError, "'#{passed_unit_string}' Unit not recognized") unless used.empty?

      @numerator = @numerator.map do |item|
        @@prefix_map[item[0]] ? [@@prefix_map[item[0]], @@unit_map[item[1]]] : [@@unit_map[item[1]]]
      end.flatten.compact.delete_if(&:empty?)

      @denominator = @denominator.map do |item|
        @@prefix_map[item[0]] ? [@@prefix_map[item[0]], @@unit_map[item[1]]] : [@@unit_map[item[1]]]
      end.flatten.compact.delete_if(&:empty?)

      @numerator = UNITY_ARRAY if @numerator.empty?
      @denominator = UNITY_ARRAY if @denominator.empty?
      self
    end
  end
end
