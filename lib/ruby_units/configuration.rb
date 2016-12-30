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
    # used to separate the scalar from the unit when generating output.
    # set to nil to prevent adding a space to the string representation of a unit
    # separators other than ' ' and '' may work, but you may encounter problems
    attr_reader :separator

    def initialize
      self.separator = true
    end

    def separator=(value)
      raise ArgumentError, "configuration 'separator' may only be true or false" unless value.class == TrueClass || value.class == FalseClass
      @separator = value ? ' ' : nil
    end
  end
end
