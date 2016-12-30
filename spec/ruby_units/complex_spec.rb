require File.dirname(__FILE__) + '/../spec_helper'

# Complex numbers are a bit strange
# Technically you can't really compare them using <=>, and ruby 1.9 does not implement this method for them
# so it stands to reason that complex units should also not support :> or :<

describe Complex do
  subject { Complex(1, 1) }
  it { is_expected.to respond_to :to_unit }
end

describe 'Complex Unit' do
  subject { Complex(1.0, -1.0).to_unit }

  it { is_expected.to be_a Unit }
  it { expect(subject.scalar).to be_a Complex }

  it { is_expected.to eq('1-1i'.to_unit) }
  it { is_expected.to be === '1-1i'.to_unit }

  it 'is not comparable' do
    expect { subject > '1+1i'.to_unit }.to raise_error(NoMethodError)
    expect { subject < '1+1i'.to_unit }.to raise_error(NoMethodError)
  end
end
