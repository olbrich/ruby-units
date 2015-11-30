require_relative '../unit_system'

RubyUnits::UnitSystem.new('International System of Units', :si)

Dir['./lib/ruby_units/unit_definitions/si/*.rb'].each { |file| require file }
