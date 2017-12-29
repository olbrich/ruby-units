require 'spec_helper'

RSpec.describe RubyUnits::Factory do
  describe '#parse(string)' do
    it 'parses a unit string into a Unit' do
      unit = described_class.new.parse('1,000 m/s^2')
      expect(unit).to be_a(RubyUnits::Unit)
    end

    it 'parses a explicit unit string into a Unit' do
      unit = described_class.new.parse('100 <meter>/<second><second>')
      expect(unit).to eq(RubyUnits::Unit.new('100 m/s^2'))
    end

    it 'parses unit with exponents' do
      unit = described_class.new.parse('10 s^2')
      expect(unit.scalar).to eq 10
    end

    it 'raises an exception when the string is empty' do
      expect { described_class.new.parse('') }.to raise_error(ArgumentError)
    end

    it 'raises an exception when the string contains an unknown unit' do
      expect { described_class.new.parse('foobar') }.to raise_error(ArgumentError)
    end
  end
end
