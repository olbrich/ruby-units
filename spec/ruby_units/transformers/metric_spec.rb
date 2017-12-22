require 'spec_helper'

RSpec.describe RubyUnits::Transformers::Metric do
  let(:parser) { RubyUnits::Parsers::Metric.new }
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


end
