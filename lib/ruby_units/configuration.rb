# frozen_string_literal: true

module RubyUnits
  class << self
    attr_writer :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  # Reset the configuration to the default values
  def self.reset
    @configuration = Configuration.new
  end

  # allow for optional configuration of RubyUnits
  #
  # Usage:
  #
  #     RubyUnits.configure do |config|
  #       config.separator = false
  #     end
  def self.configure
    yield configuration
  end

  # holds actual configuration values for RubyUnits
  class Configuration
    # Used to separate the scalar from the unit when generating output. A value
    # of `true` will insert a single space, and `false` will prevent adding a
    # space to the string representation of a unit.
    #
    # @!attribute [rw] separator
    #   @return [Boolean] whether to include a space between the scalar and the unit
    attr_reader :separator

    # The style of format to use by default when generating output. When set to `:exponential`, all units will be
    # represented in exponential notation instead of using a numerator and denominator.
    #
    # @!attribute [rw] format
    #   @return [Symbol] the format to use when generating output (:rational or :exponential) (default: :rational)
    attr_reader :format

    # Initialize configuration with keyword arguments
    #
    # @param separator [Boolean] whether to include a space between the scalar and the unit (default: true)
    # @param format [Symbol] the format to use when generating output (default: :rational)
    # @param **_options [Hash] additional keyword arguments (ignored, for forward compatibility)
    # @return [Configuration] a new configuration instance
    def initialize(separator: true, format: :rational, **_options)
      self.separator = separator
      self.format = format
    end

    # Use a space for the separator to use when generating output.
    #
    # @param value [Boolean] whether to include a space between the scalar and the unit
    # @return [void]
    def separator=(value)
      raise ArgumentError, "configuration 'separator' may only be true or false" unless [true, false].include?(value)

      @separator = value ? " " : nil
    end

    # Set the format to use when generating output.
    # The `:rational` style will generate units string like `3 m/s^2` and the `:exponential` style will generate units
    # like `3 m*s^-2`.
    #
    # @param value [Symbol] the format to use when generating output (:rational or :exponential)
    # @return [void]
    def format=(value)
      raise ArgumentError, "configuration 'format' may only be :rational or :exponential" unless %i[rational exponential].include?(value)

      @format = value
    end
  end
end
