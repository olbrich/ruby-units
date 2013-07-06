$LOAD_PATH << File.dirname(__FILE__)

require_relative 'ruby_units/namespaced'

# only include the Unit('unit') helper if we aren't fully namespaced
require_relative 'ruby_units/object'


Unit = RubyUnits::Unit
