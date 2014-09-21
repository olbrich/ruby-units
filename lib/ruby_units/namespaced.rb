$LOAD_PATH << File.dirname(__FILE__)

# require_relative this file to avoid creating an class alias from Unit to RubyUnits::Unit
require_relative 'core_ext/array'
require_relative 'core_ext/date'
require_relative 'core_ext/fixnum'
require_relative 'core_ext/math'
require_relative 'core_ext/numeric'
require_relative 'core_ext/string'
require_relative 'core_ext/time'
require_relative 'core'
