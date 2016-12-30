
$LOAD_PATH << File.dirname(__FILE__)

# require_relative this file to avoid creating an class alias from Unit to RubyUnits::Unit
require_relative 'version'
require_relative 'configuration'
require_relative 'definition'
require_relative 'cache'
require_relative 'array'
require_relative 'date'
require_relative 'time'
require_relative 'math'
require_relative 'numeric'
require_relative 'string'
require_relative 'unit'
require_relative 'unit_definitions'
