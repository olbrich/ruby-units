Unit::Definition.new("meter") do |unit|
  unit.scalar    = 1
  unit.numerator = %w{<meter>}
  unit.aliases   = %w{m meter meters metre metres}
  unit.kind      = :length
end.define!

Unit::Definition.new("kilogram") do |unit|
  unit.scalar    = 1
  unit.numerator = %w{<kilogram>}
  unit.aliases   = %w{kg kilogram kilograms}
  unit.kind      = :mass
end.define!

Unit::Definition.new("second") do |unit|
  unit.scalar    = 1
  unit.numerator = %w{<second>}
  unit.aliases   = %w{s sec second seconds}
  unit.kind      = :time
end.define!

Unit::Definition.new("mole") do |unit|
  unit.scalar    = 1
  unit.numerator = %w{<mole>}
  unit.aliases   = %w{mol mole}
  unit.kind      = :substance
end.define!

Unit::Definition.new("ampere") do |unit|
  unit.scalar    = 1
  unit.numerator = %w{<ampere>}
  unit.aliases   = %w{A Ampere ampere amp amps}
  unit.kind      = :current
end.define!

Unit::Definition.new("radian") do |unit|
  unit.scalar    = 1
  unit.numerator = %w{<radian>}
  unit.aliases   = %w{rad radian radians}
  unit.kind      = :angle
end.define!

Unit::Definition.new("kelvin") do |unit|
  unit.scalar    = 1
  unit.numerator = %w{<kelvin>}
  unit.aliases   = %w{degK kelvin}
  unit.kind      = :temperature
end.define!

Unit::Definition.new("tempK") do |unit|
  unit.scalar    = 1
  unit.numerator = %w{<tempK>}
  unit.aliases   = %w{tempK}
  unit.kind      = :temperature
end.define!

Unit::Definition.new("byte") do |unit|
  unit.scalar    = 1
  unit.numerator = %w{<byte>}
  unit.aliases   = %w{B byte}
  unit.kind      = :memory
end.define!

Unit::Definition.new("dollar") do |unit|
  unit.scalar    = 1
  unit.numerator = %w{<dollar>}
  unit.aliases   = %w{USD dollar}
  unit.kind      = :currency
end.define!

Unit::Definition.new("candela") do |unit|
  unit.scalar    = 1
  unit.numerator = %w{<candela>}
  unit.aliases   = %w{cd candela}
  unit.kind      = :luminosity
end.define!

Unit::Definition.new("each") do |unit|
  unit.scalar    = 1
  unit.numerator = %w{<each>}
  unit.aliases   = %w{each}
  unit.kind      = :counting
end.define!

Unit::Definition.new("steradian") do |unit|
  unit.scalar    = 1
  unit.numerator = %w{<steradian>}
  unit.aliases   = %w{sr steradian steradians}
  unit.kind      = :solid_angle
end.define!

Unit::Definition.new("decibel") do |unit|
  unit.scalar    = 1
  unit.numerator = %w{<decibel>}
  unit.aliases   = %w{dB decibel decibels}
  unit.kind      = :logarithmic
end.define!
