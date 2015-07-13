require File.dirname(__FILE__) + '/../spec_helper'

describe "Range" do
  
  context "of integer units" do
    subject { (Unit('1 mm')..Unit('3 mm')) }
    it { is_expected.to include(Unit('2 mm')) }

    describe '#to_a' do
      subject { super().to_a }
      it { is_expected.to eq([ Unit('1 mm'), Unit('2 mm'), Unit('3 mm') ]) }
    end
  end
  
  context "of floating point units" do
    subject { (Unit('1.5 mm')..Unit('3.5 mm')) }
    it { is_expected.to include(Unit('2.0 mm')) }
    specify { expect { subject.to_a }.to raise_exception(ArgumentError)}
  end
end