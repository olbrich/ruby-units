# allow for optional configuration of RubyUnits
#
# Usage:
#
#     RubyUnits.configure do |config|
#       config.separator = false
#     end
module RubyUnits
  class << self
    attr_writer :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.reset
    @configuration = Configuration.new
  end

  def self.configure
    yield configuration
  end

  # holds actual configuration values for RubyUnits
  class Configuration
    # Used to separate the scalar from the unit when generating output. A value
    # of `true` will insert a single space, and `false` will prevent adding a
    # space to the string representation of a unit.
    attr_reader :separator

    def initialize
      self.separator = true
    end

    def separator=(value)
      raise ArgumentError, "configuration 'separator' may only be true or false" unless value == true || value == false

      @separator = value ? ' ' : nil
    end
  end
end
