# frozen_string_literal: true

RSpec.describe Range do
  describe "of integer units" do
    subject { (RubyUnits::Unit.new("1 mm")..RubyUnits::Unit.new("3 mm")) }

    it { is_expected.to include(RubyUnits::Unit.new("2 mm")) }

    describe "#to_a" do
      subject { super().to_a }

      it {
        expect(subject).to eq([RubyUnits::Unit.new("1 mm"),
                               RubyUnits::Unit.new("2 mm"),
                               RubyUnits::Unit.new("3 mm")])
      }
    end
  end

  describe "of floating point units" do
    subject { (RubyUnits::Unit.new("1.5 mm")..RubyUnits::Unit.new("3.5 mm")) }

    it { is_expected.to include(RubyUnits::Unit.new("2.0 mm")) }
    specify { expect { subject.to_a }.to raise_exception(ArgumentError, "Non Integer Scalar") }
  end
end
