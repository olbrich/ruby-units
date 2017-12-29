require 'logger'
# allow for optional configuration of RubyUnits
#
# Usage:
#
#     RubyUnits.configure do |config|
#       config.separator = false
#       config.logger = Logger.new(STDOUT)
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
    attr_reader :separator, :logger

    def initialize
      self.separator = true
      self.logger = Logger.new(STDOUT)
      self.logger.level = Logger::INFO
    end

    def separator=(value)
      raise ArgumentError, "configuration 'separator' may only be true or false" unless value.class == TrueClass || value.class == FalseClass
      @separator = value ? ' ' : nil
    end

    def logger=(value)
      @logger=value
    end
  end
end
