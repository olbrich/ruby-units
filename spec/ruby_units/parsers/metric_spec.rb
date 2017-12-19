require 'spec_helper'
require 'parslet/rig/rspec'

RSpec.describe RubyUnits::Parsers::Metric do

  it 'parses unsigned integers' do
    expect(subject.unsigned_integer).to parse('0')
    expect(subject.unsigned_integer).to parse('1')
    expect(subject.unsigned_integer).to parse('1,000')
    expect(subject.unsigned_integer).to_not parse('01')
  end

  it 'parses integers' do
    expect(subject.integer).to parse('0')
    expect(subject.integer).to parse('1')
    expect(subject.integer).to parse('123')
    expect(subject.integer).to parse('-1')
    expect(subject.integer).to parse('+1')
    expect(subject.integer).to parse('1,000')
    expect(subject.integer).to_not parse('01')
  end

  it 'parses signs' do
    expect(subject.sign).to parse('+')
    expect(subject.sign).to parse('-')
  end

  it 'parses zero' do
    expect(subject.zero).to parse('0')
  end


end
