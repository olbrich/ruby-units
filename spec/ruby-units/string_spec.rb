require File.dirname(__FILE__) + '/../spec_helper'

describe String do
  context 'Unit creation from strings' do
    specify { expect('1 mm'.to_unit).to be_instance_of Unit }
    specify { expect('1 m'.convert_to('ft')).to be_within(RubyUnits::Unit.new('0.01 ft')).of RubyUnits::Unit.new('3.28084 ft') }
  end

  context 'output format' do
    subject { RubyUnits::Unit.new('1.23456 m/s^2') }
    specify { expect('' % subject).to eq('') }
    specify { expect('%0.2f' % subject).to eq('1.23 m/s^2') }
    specify { expect('%0.2f km/h^2' % subject).to eq('15999.90 km/h^2') }
    specify { expect('km/h^2' % subject).to eq('15999.9 km/h^2') }
    specify { expect('%H:%M:%S' % RubyUnits::Unit.new('1.5 h')).to eq('01:30:00') }
  end
end
