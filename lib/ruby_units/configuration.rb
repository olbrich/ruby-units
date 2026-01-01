# frozen_string_literal: true

# RubyUnits provides a comprehensive unit conversion and manipulation library for Ruby.
# It allows for the creation, conversion, and mathematical operations on physical quantities
# with associated units of measurement.
module RubyUnits
  # Raised when a requested feature cannot be enabled because a runtime
  # dependency has not been loaded by the caller.
  class MissingDependencyError < StandardError; end
  class << self
    # Get or initialize the configuration
    # @return [Configuration] the configuration instance
    def configuration
      @configuration ||= Configuration.new
    end
  end

  # Reset the configuration to the default values
  def self.reset
    @configuration = Configuration.new
  end

  # Allow for optional configuration of RubyUnits
  #
  # Usage:
  #
  #     RubyUnits.configure do |config|
  #       config.separator = :none
  #     end
  def self.configure
    yield configuration
  end

  # Configuration class for RubyUnits
  #
  # This class manages global configuration settings that control how units are
  # formatted and represented throughout the RubyUnits library. It provides a
  # centralized way to customize output behavior without modifying individual
  # Unit instances.
  #
  # == Configuration Options
  #
  # [separator]
  #   Controls the spacing between numeric values and unit strings in output.
  #   - `:space` (default): Adds a single space (e.g., "5 m")
  #   - `:none`: No space is added (e.g., "5m")
  #
  # [format]
  #   Determines the notation style for unit representation.
  #   - `:rational` (default): Uses numerator/denominator notation (e.g., "3 m/s^2")
  #   - `:exponential`: Uses exponential notation (e.g., "3 m*s^-2")
  #
  # [default_precision]
  #   Sets the precision level when converting fractional unit values to rationals.
  #   Default is 0.0001. Must be a positive number.
  #
  # == Usage
  #
  #   # Access global configuration
  #   config = RubyUnits.configuration
  #
  #   # Configure via block
  #   RubyUnits.configure do |config|
  #     config.separator = :none
  #     config.format = :exponential
  #     config.default_precision = 0.0001
  #   end
  #
  #   # Reset to defaults
  #   RubyUnits.reset
  #
  class Configuration
    # Used to separate the scalar from the unit when generating output. A value
    # of `:space` will insert a single space, and `:none` will prevent adding a
    # space to the string representation of a unit.
    #
    # @!attribute [rw] separator
    #   @return [String, nil] the separator string (" " for :space, nil for :none)
    attr_reader :separator

    # The style of format to use by default when generating output. When set to `:exponential`, all units will be
    # represented in exponential notation instead of using a numerator and denominator.
    #
    # @!attribute [rw] format
    #   @return [Symbol] the format to use when generating output (:rational or :exponential) (default: :rational)
    attr_reader :format

    # The default precision to use when rationalizing fractional values in unit output.
    #
    # @!attribute [rw] default_precision
    #   @return [Numeric] the precision to use when converting to a rational (default: 0.0001)
    attr_reader :default_precision

    # Whether to parse numeric literals as BigDecimal when parsing unit strings.
    # This is an opt-in feature because BigDecimal has different performance
    # and precision characteristics compared to Float. The default is `false`.
    #
    # When enabled, numeric strings parsed from unit inputs will be converted
    # to BigDecimal. The caller must require the BigDecimal library before
    # enabling this mode (for example `require 'bigdecimal'`).
    #
    # @!attribute [rw] use_bigdecimal
    #   @return [Boolean] whether to coerce numeric literals to BigDecimal (default: false)
    attr_reader :use_bigdecimal

    # Initialize configuration with keyword arguments.
    #
    # Accepts keyword options to set initial configuration values. Each value
    # is validated by the corresponding setter method; invalid values will
    # raise an error (see @raise tags below). Boolean values for
    # `separator` are accepted for backward compatibility but will emit a
    # deprecation warning.
    #
    # @param opts [Hash] the keyword options hash
    # @option opts [Symbol, Boolean] :separator One of `:space` or `:none`.
    #   Boolean `true`/`false` are accepted for backward compatibility
    #   (`true` -> `:space`, `false` -> `:none`) and will emit a deprecation
    #   warning. Internally a `:space` separator is stored as a single space
    #   string (" ") and `:none` is stored as `nil`. Default: `:space`.
    # @option opts [Symbol] :format The output format, one of `:rational` or
    #   `:exponential`. Default: `:rational`.
    # @option opts [Numeric] :default_precision Positive numeric precision
    #   used when rationalizing fractional values. Default: `0.0001`.
    # @option opts [Boolean] :use_bigdecimal When `true`, numeric literals
    #   parsed from unit input strings will be coerced to `BigDecimal`.
    #   The caller must require the BigDecimal library before enabling this
    #   option. Default: `false`.
    #
    # @raise [ArgumentError] If any provided value fails validation (invalid
    #   `separator`, invalid `format`, non-positive `default_precision`, or
    #   non-boolean `use_bigdecimal`).
    # @raise [MissingDependencyError] If `use_bigdecimal` is enabled but the
    #   `BigDecimal` library has not been required.
    #
    # @example
    #   Configuration.new(
    #     separator: :none,
    #     format: :exponential,
    #     default_precision: 1e-6,
    #     use_bigdecimal: false
    #   )
    #
    # @return [Configuration] a new configuration instance
    def initialize(**opts)
      separator = opts.fetch(:separator, :space)
      format = opts.fetch(:format, :rational)
      default_precision = opts.fetch(:default_precision, 0.0001)
      use_bigdecimal = opts.fetch(:use_bigdecimal, false)

      self.separator = separator
      self.format = format
      self.default_precision = default_precision
      self.use_bigdecimal = use_bigdecimal
    end

    # Set the separator to use when generating output.
    #
    # @param value [Symbol, Boolean] the separator to use (:space or :none, true/false for backward compatibility)
    # @return [void]
    def separator=(value)
      normalized_value = normalize_separator_value(value)
      validate_separator_value(normalized_value)
      @separator = normalized_value == :space ? " " : nil
    end

    private

    # Normalize deprecated boolean separator values to symbols
    # @param value [Symbol, Boolean] the separator value
    # @return [Symbol] the normalized separator value
    def normalize_separator_value(value)
      return value unless [true, false].include?(value)

      warn "DEPRECATION WARNING: Using boolean values for separator is deprecated. Use :space instead of true and :none instead of false."
      value ? :space : :none
    end

    # Validate the separator value
    # @param value [Symbol] the separator value to validate
    # @return [void]
    # @raise [ArgumentError] if the value is not valid
    def validate_separator_value(value)
      return if %i[space none].include?(value)

      raise ArgumentError, "configuration 'separator' may only be :space or :none"
    end

    public

    # Set the format to use when generating output.
    # The `:rational` style will generate unit strings like `3 m/s^2` and the `:exponential` style will generate units
    # like `3 m*s^-2`.
    #
    # @param value [Symbol] the format to use when generating output (:rational or :exponential)
    # @return [void]
    def format=(value)
      raise ArgumentError, "configuration 'format' may only be :rational or :exponential" unless %i[rational exponential].include?(value)

      @format = value
    end

    # Set the default precision to use when rationalizing fractional values.
    #
    # @param value [Numeric] the precision to use when converting to a rational
    # @return [void]
    def default_precision=(value)
      raise ArgumentError, "configuration 'default_precision' must be a positive number" unless value.is_a?(Numeric) && value.positive?

      @default_precision = value
    end

    # Enable or disable BigDecimal parsing for numeric literals.
    #
    # To enable BigDecimal parsing, the BigDecimal library must already be
    # required by the application. If you attempt to enable this option
    # without requiring BigDecimal first a `MissingDependencyError` will be
    # raised to make the dependency requirement explicit.
    #
    # @param value [Boolean]
    # @return [void]
    # @raise [ArgumentError] if `value` is not a boolean
    # @raise [MissingDependencyError] when enabling without requiring BigDecimal first
    # @example
    #   require 'bigdecimal'
    #   require 'bigdecimal/util' # for to_d method (optional)
    #   RubyUnits.configuration.use_bigdecimal = true
    def use_bigdecimal=(value)
      raise ArgumentError, "configuration 'use_bigdecimal' must be a boolean" unless [true, false].include?(value)

      raise MissingDependencyError, "To enable use_bigdecimal, require 'bigdecimal' before setting RubyUnits.configuration.use_bigdecimal = true" if value && !defined?(BigDecimal)

      @use_bigdecimal = value
    end
  end
end
