RubyUnits::UnitSystem.new('International System of Units', :si) do
  define_base(:meter) do
    numerator %i(meter)
    aliases %w(m meter meters metre metres)
    kind :length
  end

  define_base(:kilogram) do
    numerator %i(kilogram)
    aliases %w(kg kilogram kilograms)
    kind :mass
  end

  define_base(:second) do
    numerator %i(second)
    aliases %w(s sec second seconds)
    kind :time
  end

  define_base(:mole) do
    numerator %i(mole)
    aliases %w(mol mole)
    kind :substance
  end

  define_base(:ampere) do
    numerator %i(ampere)
    aliases %w(A ampere amperes amp amps)
    kind :current
  end

  define_base(:radian) do
    numerator %i(radian)
    aliases %w(rad radian radians)
    kind :angle
  end

  define_base(:kelvin) do
    numerator %i(kelvin)
    aliases %w(degK kelvin)
    kind :temperature
  end

  define_base(:tempK) do
    numerator %i(tempK)
    aliases %w(tempK)
    kind :temperature
  end

  define_base(:byte) do
    numerator %i(byte)
    aliases %w(B byte bytes)
    kind :information
  end

  define_base(:dollar) do
    numerator %i(dollar)
    aliases %w($ USD dollar)
    kind :currency
  end

  define_base(:candela) do
    numerator %i(candela)
    aliases %w(cd candela)
    kind :luminosity
  end

  define_base(:each) do
    numerator %i(each)
    aliases %w(each ea)
    kind :counting
  end

  define_base(:steradian) do
    numerator %i(steradian)
    aliases %w(sr steradian steradians)
    kind :solid_angle
  end

  define_base(:decibel) do
    numerator %i(decibel)
    aliases %w(dB decibel decibels)
    kind :logarithmic
  end
end
