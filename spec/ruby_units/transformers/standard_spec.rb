require 'spec_helper'

RSpec.describe RubyUnits::Transformers::Standard do
  let(:parser) { RubyUnits::Parsers::Standard.new }
  it 'constructs a unit from a parse tree' do
    result = parser.parse('-1 m/s/s')
    expect(subject.apply(result)).to eq RubyUnits::Unit.new('-1 m/s^2')
  end

  it 'constructs a unit from a parse tree' do
    result = parser.parse('+1 m/s^2')
    expect(subject.apply(result)).to eq RubyUnits::Unit.new('1 m/s^2')
  end

  it 'constructs a unit from a parse tree' do
    result = parser.parse('-1.5 kg*m/s^2')
    expect(subject.apply(result)).to eq RubyUnits::Unit.new('-1.5 kg*m/s^2')
  end

  it 'constructs a unit from a parse tree' do
    result = parser.parse('1e4 m')
    expect(subject.apply(result)).to eq RubyUnits::Unit.new('1E4 m')
  end

  it 'constructs a unit from a parse tree' do
    result = parser.parse('10,000 m')
    expect(subject.apply(result)).to eq RubyUnits::Unit.new('1E4 m')
  end


  it 'constructs a unit from a parse tree' do
    result = parser.parse('1.05e-4 m')
    expect(subject.apply(result)).to eq RubyUnits::Unit.new('1.05E-4 m')
  end

  it 'constructs a unit from a parse tree' do
    result = parser.parse('-1 3/4 cu')
    expect(subject.apply(result)).to eq RubyUnits::Unit.new('-1 3/4 cu')
  end

  it 'constructs a unit from a parse tree' do
    result = parser.parse('-1-3i rad')
    expect(subject.apply(result)).to eq RubyUnits::Unit.new('-1-3i rad')
  end

  it 'constructs a unit from a parse tree' do
    result = parser.parse('1 ft x lb')
    expect(subject.apply(result)).to eq RubyUnits::Unit.new('1 ft*lb')
  end

  it 'constructs a unit from a foot-in' do
    result = parser.parse('6 foot 4')
    expect(subject.apply(result)).to eq RubyUnits::Unit.new('6 ft') + RubyUnits::Unit.new('4 in')
  end

  it 'constructs a unit from a lbs-oz' do
    result = parser.parse('10 lbs 8 oz')
    expect(subject.apply(result)).to eq RubyUnits::Unit.new('10 lbs') + RubyUnits::Unit.new('8 oz')
  end

end
