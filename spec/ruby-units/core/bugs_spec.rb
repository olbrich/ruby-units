require_relative 'spec_helper'

module RubyUnits

  describe "Github issue #49" do
    let(:a) { Unit.new("3 cm^3")}
    let(:b) { Unit.new(a)}

    it "should subtract a unit properly from one initialized with a unit" do
      expect(b - Unit.new("1.5 cm^3")).to eq(Unit.new("1.5 cm^3"))
    end
  end

end
