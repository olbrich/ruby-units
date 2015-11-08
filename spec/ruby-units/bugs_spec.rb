require File.dirname(__FILE__) + '/../spec_helper'

describe 'Github issue #49' do
  let(:a) { RubyUnits::Unit.new('3 cm^3') }
  let(:b) { RubyUnits::Unit.new(a) }

  it 'should subtract a unit properly from one initialized with a unit' do
    expect(b - RubyUnits::Unit.new('1.5 cm^3')).to eq(RubyUnits::Unit.new('1.5 cm^3'))
  end
end
