# frozen_string_literal: true

# RubyUnits provides a comprehensive unit conversion and manipulation library for Ruby.
# It allows for the creation, conversion, and mathematical operations on physical quantities
# with associated units of measurement.
module RubyUnits
  class << self
    # @api private
    # :reek:Attribute
    attr_writer :configuration

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

  # Holds actual configuration values for RubyUnits
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

    # Initialize configuration with keyword arguments
    #
    # @param separator [Symbol, Boolean] the separator to use (:space or :none, true/false for backward compatibility) (default: :space)
    # @param format [Symbol] the format to use when generating output (:rational or :exponential) (default: :rational)
    # @param default_precision [Numeric] the precision to use when converting to a rational (default: 0.0001)
    # @return [Configuration] a new configuration instance
    def initialize(separator: :space, format: :rational, default_precision: 0.0001)
      self.separator = separator
      self.format = format
      self.default_precision = default_precision
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
  end
end
