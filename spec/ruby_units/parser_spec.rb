require 'spec_helper'

RSpec.describe RubyUnits::Parser do
  describe 'parses' do
    it '1 foo' do
      result = described_class.new('1 foo').parse
      expect(result).to eq [1, 'foo']
    end
    it '1 foo*bar'
    it '1 foo/100 bar'
    it 'foo**2'
    it 'foo**(1/2)'
    it 'foo**(0.5)'
    it 'foo**(-1)'
    it 'foo/bar'
    it 'foo/bar/bar'
    it '6ft, 2in'
    it '8 lbs 4 oz'
    it '3 stone 5'
  end
end
