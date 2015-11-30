RubyUnits::UnitSystem.registered[:si].extend do
  base(:meter) do
    aliases %w(m meter meters metre metres)
    kind :length
  end

  base(:kilogram) do
    aliases %w(kg kilogram kilograms)
    kind :mass
  end

  base(:second) do
    aliases %w(s sec second seconds)
    kind :time
  end

  base(:mole) do
    aliases %w(mol mole)
    kind :substance
  end

  base(:ampere) do
    aliases %w(A ampere amperes amp amps)
    kind :current
  end

  base(:radian) do
    aliases %w(rad radian radians)
    kind :angle
  end

  base(:kelvin) do
    aliases %w(degK kelvin)
    kind :temperature
  end

  base(:tempK) do
    aliases %w(tempK)
    kind :temperature
  end

  base(:byte) do
    aliases %w(B byte bytes)
    kind :information
  end

  base(:dollar) do
    aliases %w(USD dollar)
    kind :currency
  end

  base(:candela) do
    aliases %w(cd candela)
    kind :luminosity
  end

  base(:each) do
    aliases %w(each ea)
    kind :counting
  end

  base(:steradian) do
    aliases %w(sr steradian steradians)
    kind :solid_angle
  end

  base(:decibel) do
    aliases %w(dB decibel decibels)
    kind :logarithmic
  end
end
