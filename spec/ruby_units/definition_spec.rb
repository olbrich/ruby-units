require File.dirname(__FILE__) + '/../spec_helper'

# Meter is a base unit so the definition is simple
describe 'definition of meter' do
  subject(:meter) { RubyUnits::Unit.definition('meter') }
  specify do
    expect(meter).to be_a RubyUnits::Unit::Definition
    expect(meter.aliases).to eq %w[m meter meters metre metres]
    expect(meter.base?).to eq true
    expect(meter.complexity).to eq 1
    expect(meter.denominator).to eq RubyUnits::Unit::UNITY_ARRAY
    expect(meter.display_name).to eq 'm'
    expect(meter.kind).to eq :length
    expect(meter.name).to eq '<meter>'
    expect(meter.numerator).to eq ['<meter>']
    expect(meter.prefix?).to eq false
    expect(meter.scalar).to eq 1
    expect(meter.signature).to eq 31
    expect(meter.system).to eq :si
  end
end

# Inch is defined in terms of meters
describe 'definition of inch' do
  subject(:inch) { RubyUnits::Unit.definition('inch') }
  specify do
    expect(inch).to be_a RubyUnits::Unit::Definition
    expect(inch.aliases).to eq ['in', 'inch', 'inches', '"']
    expect(inch.base?).to eq false # because it's defined in terms of meters
    expect(inch.complexity).to eq 1
    expect(inch.denominator).to eq RubyUnits::Unit::UNITY_ARRAY
    expect(inch.display_name).to eq 'in'
    expect(inch.kind).to eq :length
    expect(inch.name).to eq '<inch>'
    expect(inch.numerator).to eq ['<meter>']
    expect(inch.prefix?).to eq false
    expect(inch.scalar).to eq Rational(127, 5000)
    expect(inch.signature).to eq RubyUnits::Unit::LENGTH
    expect(inch.system).to eq :imperial
  end
end

# sqft is defined as the square of another unit
describe 'definition of sqft' do
  subject(:sqft) { RubyUnits::Unit.definition('sqft') }
  specify do
    expect(sqft).to be_a RubyUnits::Unit::Definition
    expect(sqft.aliases).to eq ['sqft']
    expect(sqft.base?).to eq false
    expect(sqft.complexity).to eq 2
    expect(sqft.denominator).to eq RubyUnits::Unit::UNITY_ARRAY
    expect(sqft.display_name).to eq 'sqft'
    expect(sqft.kind).to eq :area
    expect(sqft.name).to eq '<sqft>'
    expect(sqft.numerator).to eq ['<meter>', '<meter>']
    expect(sqft.prefix?).to eq false
    expect(sqft.scalar).to eq Rational(145_161, 1_562_500)
    expect(sqft.signature).to eq RubyUnits::Unit::LENGTH**2
    expect(sqft.system).to eq :imperial
  end
end

# kph is a rate (LENGTH/TIME) so it's defined in terms of a unit divided by
# another
describe 'definition of kph' do
  subject(:kph) { RubyUnits::Unit.definition('kph') }
  specify do
    expect(kph).to be_a RubyUnits::Unit::Definition
    expect(kph.aliases).to eq ['kph']
    expect(kph.base?).to eq false
    expect(kph.complexity).to eq 2
    expect(kph.denominator).to eq ['<second>']
    expect(kph.display_name).to eq 'kph'
    expect(kph.kind).to eq :speed
    expect(kph.name).to eq '<kph>'
    expect(kph.numerator).to eq ['<meter>']
    expect(kph.prefix?).to eq false
    expect(kph.scalar).to eq 0.2777777777777778
    expect(kph.signature).to eq Rational(RubyUnits::Unit::LENGTH, RubyUnits::Unit::TIME)
    expect(kph.system).to eq :si
  end
end

# Hz is a frequency (1/TIME) so it's defined in terms of unity divided by time
describe 'definition of Hz' do
  subject(:hz) { RubyUnits::Unit.definition('hertz') }
  specify do
    expect(hz).to be_a RubyUnits::Unit::Definition
    expect(hz.aliases).to eq %w[Hz hertz]
    expect(hz.base?).to eq false
    expect(hz.complexity).to eq 1
    expect(hz.denominator).to eq ['<second>']
    expect(hz.display_name).to eq 'Hz'
    expect(hz.kind).to eq :frequency
    expect(hz.name).to eq '<hertz>'
    expect(hz.numerator).to eq RubyUnits::Unit::UNITY_ARRAY
    expect(hz.prefix?).to eq false
    expect(hz.scalar).to eq 1
    expect(hz.signature).to eq Rational(1, RubyUnits::Unit::TIME)
    expect(hz.system).to eq :si
  end
end

# percent is a unitless ratio
describe 'definition of percent' do
  subject(:percent) { RubyUnits::Unit.definition('percent') }
  specify do
    expect(percent).to be_a RubyUnits::Unit::Definition
    expect(percent.aliases).to eq ['%', 'percent']
    expect(percent.base?).to eq false
    expect(percent.complexity).to eq 0
    expect(percent.denominator).to eq RubyUnits::Unit::UNITY_ARRAY
    expect(percent.display_name).to eq '%'
    expect(percent.kind).to eq :unitless
    expect(percent.name).to eq '<percent>'
    expect(percent.numerator).to eq RubyUnits::Unit::UNITY_ARRAY
    expect(percent.prefix?).to eq false
    expect(percent.scalar).to eq Rational(1, 100)
    expect(percent.signature).to eq RubyUnits::Unit::UNITLESS
    expect(percent.system).to be_nil # percent is not part of any unit system
  end
end

describe 'new unit definition for electron volt (not normally definied)' do
  subject do
    Unit::Definition.new('eV') do |ev|
      ev.aliases      = ['eV', 'electron-volt']
      ev.definition   = RubyUnits::Unit.new('1.602E-19 joule')
      ev.display_name = 'electron-volt'
    end
  end

  describe '#name' do
    subject { super().name }
    it { is_expected.to eq('<eV>') }
  end

  describe '#aliases' do
    subject { super().aliases }
    it { is_expected.to eq(%w[eV electron-volt]) }
  end

  describe '#scalar' do
    subject { super().scalar }
    it { is_expected.to eq(1.602E-19) }
  end

  describe '#numerator' do
    subject { super().numerator }
    it { is_expected.to include('<kilogram>', '<meter>', '<meter>') }
  end

  describe '#denominator' do
    subject { super().denominator }
    it { is_expected.to include('<second>', '<second>') }
  end

  describe '#display_name' do
    subject { super().display_name }
    it { is_expected.to eq('electron-volt') }
  end

  describe '#complexity' do
    subject { super().complexity }
    it { is_expected.to eq 5 }
  end
end
