# Japanese standard unit for land
# https://en.wikipedia.org/wiki/Japanese_units_of_measurement
RubyUnits::Unit.define('tsubo') do |tsubo|
  tsubo.definition = RubyUnits::Unit.new('3.30579 m^2')
end
