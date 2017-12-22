require 'spec_helper'
require 'parslet/rig/rspec'
require './lib/ruby_units/parsers/ucum'

RSpec.describe RubyUnits::Parsers::UCUM do

  it 'parses annotations' do
    expect(subject.annotation).to parse('{RBC}')
  end

  it 'parses unsigned integers' do
    expect(subject.unsigned_integer).to parse('0')
    expect(subject.unsigned_integer).to parse('1')
    expect(subject.unsigned_integer).to_not parse('01')
  end

  it 'parses integers' do
    expect(subject.integer).to parse('0')
    expect(subject.integer).to parse('1')
    expect(subject.integer).to parse('123')
    expect(subject.integer).to parse('-1')
    expect(subject.integer).to parse('+1')
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

  it 'parses decimals' do
    expect(subject.decimal).to parse('1234.567')
    expect(subject.decimal).to parse('+1234.567')
    expect(subject.decimal).to parse('-1234.567')
    expect(subject.decimal).to parse('0.567')
  end

  it 'parses rationals' do
    expect(subject.rational).to parse('1/2')
    expect(subject.rational).to parse('-1/2')
    expect(subject.rational).to parse('+1/2')
    expect(subject.rational).to parse('1/0.5')
    expect(subject.rational).to parse('1.5/3.0')
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
    expect(subject.scalar).to parse('1+1i')
  end

  it 'parses unit_atom' do
    expect(subject.unit_atom).to parse('m')
    expect(subject.unit_atom).to parse('mm')
    expect(subject.unit_atom).to parse('m2')
    expect(subject.unit_atom).to parse('m+2')
    expect(subject.unit_atom).to parse('m-2')
  end

  it 'parses a unit' do
    expect(subject.unit).to_not parse('')
    expect(subject.unit).to parse('/m')
    expect(subject.unit).to parse('1 kg.m/s2')
    expect(subject.unit).to parse('1 m3.kg-1.s-2')
    expect(subject.unit).to parse('/M')
    expect(subject.unit).to parse('1 KG.M/S2')
    expect(subject.unit).to parse('1 M3.KG-1.S-2')
    expect(subject.unit).to parse('10*-2')
    expect(subject.unit.parse('10*-2')).to eq({})
  end

  it 'parses exponents' do
    expect(subject.exponent).to parse('10*-2')

  end
end
