require File.dirname(__FILE__) + '/../spec_helper'

describe Array do
  subject { [1, 'cm'] }

  it { is_expected.to be_kind_of Array }
  it { is_expected.to respond_to :to_unit }

  specify { expect(subject.to_unit).to be_instance_of Unit }
  specify { expect(subject.to_unit).to eq('1 cm'.to_unit) }
  specify { expect(subject.to_unit('mm')).to eq('10 mm'.to_unit) }
end
