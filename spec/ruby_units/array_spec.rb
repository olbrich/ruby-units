RSpec.describe RubyUnits::Array do
  subject(:array_unit) { array.to_unit }

  let(:array) { [1, 'cm'] }

  it { is_expected.to be_a RubyUnits::Unit }
  it { expect(array).to respond_to :to_unit }

  it {
    expect(array_unit).to have_attributes(
      kind: :length,
      scalar: 1,
      units: 'cm'
    )
  }
end
