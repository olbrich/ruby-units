# seed the cache
RubyUnits::Unit.new('1')

RubyUnits::Unit.define('meter') do |unit|
  unit.scalar    = 1
  unit.numerator = %w[<meter>]
  unit.aliases   = %w[m meter meters metre metres]
  unit.kind      = :length
  unit.system    = :si
end

RubyUnits::Unit.define('kilogram') do |unit|
  unit.scalar    = 1
  unit.numerator = %w[<kilogram>]
  unit.aliases   = %w[kg kilogram kilograms]
  unit.kind      = :mass
  unit.system    = :si
end

RubyUnits::Unit.define('second') do |unit|
  unit.scalar    = 1
  unit.numerator = %w[<second>]
  unit.aliases   = %w[s sec second seconds]
  unit.kind      = :time
  unit.system    = :si
end

RubyUnits::Unit.define('mole') do |unit|
  unit.scalar    = 1
  unit.numerator = %w[<mole>]
  unit.aliases   = %w[mol mole]
  unit.kind      = :substance
  unit.system    = :si
end

RubyUnits::Unit.define('ampere') do |unit|
  unit.scalar    = 1
  unit.numerator = %w[<ampere>]
  unit.aliases   = %w[A ampere amperes amp amps]
  unit.kind      = :current
  unit.system    = :si
end

RubyUnits::Unit.define('radian') do |unit|
  unit.scalar    = 1
  unit.numerator = %w[<radian>]
  unit.aliases   = %w[rad radian radians]
  unit.kind      = :angle
  unit.system    = :si
end

RubyUnits::Unit.define('kelvin') do |unit|
  unit.scalar    = 1
  unit.numerator = %w[<kelvin>]
  unit.aliases   = %w[degK kelvin]
  unit.kind      = :temperature
  unit.system    = :si
end

RubyUnits::Unit.define('tempK') do |unit|
  unit.scalar    = 1
  unit.numerator = %w[<tempK>]
  unit.aliases   = %w[tempK]
  unit.kind      = :temperature
  unit.system    = :si
end

RubyUnits::Unit.define('byte') do |unit|
  unit.scalar    = 1
  unit.numerator = %w[<byte>]
  unit.aliases   = %w[B byte bytes]
  unit.kind      = :information
  unit.system    = :si
end

RubyUnits::Unit.define('dollar') do |unit|
  unit.scalar    = 1
  unit.numerator = %w[<dollar>]
  unit.aliases   = %w[USD dollar]
  unit.kind      = :currency
  unit.system    = :money
end

RubyUnits::Unit.define('candela') do |unit|
  unit.scalar    = 1
  unit.numerator = %w[<candela>]
  unit.aliases   = %w[cd candela]
  unit.kind      = :luminosity
  unit.system    = :si
end

RubyUnits::Unit.define('each') do |unit|
  unit.scalar    = 1
  unit.numerator = %w[<each>]
  unit.aliases   = %w[each]
  unit.kind      = :counting
end

RubyUnits::Unit.define('steradian') do |unit|
  unit.scalar    = 1
  unit.numerator = %w[<steradian>]
  unit.aliases   = %w[sr steradian steradians]
  unit.kind      = :solid_angle
  unit.system    = :si
end

RubyUnits::Unit.define('decibel') do |unit|
  unit.scalar    = 1
  unit.numerator = %w[<decibel>]
  unit.aliases   = %w[dB decibel decibels]
  unit.kind      = :logarithmic
  unit.system    = :si
end
