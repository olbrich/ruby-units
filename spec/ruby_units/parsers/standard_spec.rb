require 'spec_helper'
require 'parslet/rig/rspec'

RSpec.describe RubyUnits::Parsers::Standard do

  it 'parses unsigned integers' do
    expect(subject.unsigned_integer).to parse('0')
    expect(subject.unsigned_integer).to parse('1')
    expect(subject.unsigned_integer).to parse('1,000')
    expect(subject.unsigned_integer).to_not parse('01')
    expect(subject.unsigned_integer).to_not parse('-1')
    expect(subject.unsigned_integer).to_not parse('+1')
  end

  it 'parses integers' do
    expect(subject.integer).to parse('0')
    expect(subject.integer).to parse('1')
    expect(subject.integer).to parse('123')
    expect(subject.integer).to parse('-1')
    expect(subject.integer).to parse('+1')
    expect(subject.integer).to parse('1,000')
    expect(subject.integer).to parse('-1,000')
    expect(subject.integer).to_not parse('01')
  end

  it 'parses signs' do
    expect(subject.sign).to parse('+')
    expect(subject.sign).to parse('-')
  end

  it 'parses zero' do
    expect(subject.zero).to parse('0')
  end

  it 'parses digits' do
    expect(subject.digits).to_not parse('')
    expect(subject.digits).to parse('0')
    expect(subject.digits).to parse('1')
    expect(subject.digits).to parse('2')
    expect(subject.digits).to parse('3')
    expect(subject.digits).to parse('4')
    expect(subject.digits).to parse('5')
    expect(subject.digits).to parse('6')
    expect(subject.digits).to parse('7')
    expect(subject.digits).to parse('8')
    expect(subject.digits).to parse('9')
    expect(subject.digits).to parse('12345') # more than one digit
    expect(subject.digits).to parse('0000012345') # can have leading zeros
  end

  it 'parses integers with separators' do
    expect(subject.integer_with_separators).to parse('1,000')
    expect(subject.integer_with_separators).to parse('-1,000')
    expect(subject.integer_with_separators).to parse('10,000')
    expect(subject.integer_with_separators).to parse('100,000')
    expect(subject.integer_with_separators).to parse('1,000,000')
    expect(subject.integer_with_separators).to_not parse('10,00,00')
    expect(subject.integer_with_separators).to parse('1_000')
    expect(subject.integer_with_separators).to parse('10_000')
    expect(subject.integer_with_separators).to parse('100_000')
    expect(subject.integer_with_separators).to parse('1_000_000')
    expect(subject.integer_with_separators).to parse('12,345')
    expect(subject.integer_with_separators).to parse('-12,345')
    expect(subject.integer_with_separators).to_not parse('1000_000')
  end

  it 'parses decimals' do
    expect(subject.decimal).to parse('1234.567')
    expect(subject.decimal).to parse('+1234.567')
    expect(subject.decimal).to parse('-1234.567')
    expect(subject.decimal).to parse('0.567')
    expect(subject.decimal).to parse('12,345.56')
    expect(subject.decimal).to parse('-12,345.56')
    expect(subject.decimal).to parse('+12,345.56')
  end

  it 'parses rationals' do
    expect(subject.rational).to parse('1/2')
    expect(subject.rational).to parse('-1/2')
    expect(subject.rational).to parse('+1/2')
    expect(subject.rational).to parse('1/0.5')
    expect(subject.rational).to parse('1.5/3.0')
  end

  it 'parses mixed fractions' do
    expect(subject.mixed_fraction).to parse('1 3/4')
    expect(subject.mixed_fraction).to parse('1-3/4')
    expect(subject.mixed_fraction).to parse('-1 3/4')
  end

  it 'parses scientific notation' do
    expect(subject.scientific).to parse('1.23E45')
    expect(subject.scientific).to parse('+1.23E45')
    expect(subject.scientific).to parse('-1.23E45')
    expect(subject.scientific).to parse('1.23E+45')
    expect(subject.scientific).to parse('1.23E-45')
  end

  it 'parses complex numbers' do
    expect(subject.complex).to parse('1+1i')
    expect(subject.complex).to parse('1-1i')
    expect(subject.complex).to parse('-1+1i')
    expect(subject.complex).to parse('-1-1i')
  end

  it 'parses scalars' do
    expect(subject.scalar).to parse('1')
    expect(subject.scalar).to parse('1.5')
    expect(subject.scalar).to parse('1 1/2')
    expect(subject.scalar).to parse('1+1i')
  end

  it 'parses unit_atom' do
    expect(subject.unit_atom).to parse('1')
    expect(subject.unit_atom).to parse('-1')
    expect(subject.unit_atom).to parse('+1')
    expect(subject.unit_atom).to parse('1,000')
    expect(subject.unit_atom).to parse('-1,000')
    expect(subject.unit_atom).to parse('+1,000')
    expect(subject.unit_atom).to parse('-1.2E4')
    expect(subject.unit_atom).to parse('-1.2E-4')
    expect(subject.unit_atom).to parse('1.2E+4')
    expect(subject.unit_atom).to parse('1/2')
    expect(subject.unit_atom).to parse('-1/2')
    expect(subject.unit_atom).to parse('m')
    expect(subject.unit_atom).to parse('mm')
    expect(subject.unit_atom).to parse('1 m')
    expect(subject.unit_atom).to parse('1,000 m')
    expect(subject.unit_atom).to parse('1 mm')
    expect(subject.unit_atom).to parse('1 mm^-2')
    expect(subject.unit_atom).to parse('1 mm^0.5')
    expect(subject.unit_atom).to parse('1 mm^2')
    expect(subject.unit_atom).to parse('1 mm**-2')
    expect(subject.unit_atom).to parse('1 mm**0.5')
    expect(subject.unit_atom).to parse('10 mm**2')
  end

  it 'parses a unit' do
    expect(subject.unit).to parse('1 mm/s/s')
    expect(subject.unit).to parse('1 m*m/s/s')
    expect(subject.unit).to parse('1 <meter>*<meter>')
    expect(subject.unit).to parse('1 <meter>/<second>')
  end

  it 'parses ft-in' do
    expect(subject.feet_inches).to parse('6ft 4in')
    expect(subject.feet_inches).to parse('6 ft 4 in')
    expect(subject.feet_inches).to parse('6 feet 4 inches')
    expect(subject.feet_inches).to parse('1 foot 1 inch')
    expect(subject.feet_inches).to parse(%Q{6' 4"})
    expect(subject.feet_inches).to parse('6 foot 4')
  end

  it 'parses lbs-oz' do
    expect(subject.lbs_oz).to parse('4 lbs 4 oz')
    expect(subject.lbs_oz).to parse('1 pound 6 ounces')
    expect(subject.lbs_oz).to parse('4 pounds 1 ounce')
  end

  it 'parses stone-lbs' do
    expect(subject.stone).to parse('4 stone 4 lbs')
    expect(subject.stone).to parse('1 st 6')
    expect(subject.stone).to parse('4 stone 1')
    expect(subject.stone).to parse('10st 4')
  end

  it 'parses times' do
    expect(subject.times).to parse('1:23')
    expect(subject.times).to parse('1:23:45')
    expect(subject.times).to parse('1:23:45,200')
  end

  it 'parses the unit_part' do
    expect(subject.unit_part).to parse('<kilogram>')
  end
end
