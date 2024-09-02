# frozen_string_literal: true

RSpec.describe Complex do
  subject { Complex(1.0, -1.0).to_unit }

  it { expect(Complex(1, 1)).to respond_to :to_unit }
  it { is_expected.to be_a Unit }
  it { expect(subject.scalar).to be_a Complex }

  it { is_expected.to eq("1-1i".to_unit) }

  # Complex numbers are a bit strange. Technically you can't really compare them
  # using :<=>, and Ruby < 2.7 does not implement this method for them so it
  # stands to reason that complex units should also not support :> or :<.
  #
  # This inconsistency was corrected in Ruby 2.7.
  # @see https://rubyreferences.github.io/rubychanges/2.7.html#complex
  # @see https://bugs.ruby-lang.org/issues/15857
  it "is not comparable" do
    if subject.scalar.respond_to?(:<=>) # this is true for Ruby >= 2.7
      expect { subject > "1+1i".to_unit }.to raise_error(ArgumentError)
      expect { subject < "1+1i".to_unit }.to raise_error(ArgumentError)
    else
      expect { subject > "1+1i".to_unit }.to raise_error(NoMethodError)
      expect { subject < "1+1i".to_unit }.to raise_error(NoMethodError)
    end
  end
end
