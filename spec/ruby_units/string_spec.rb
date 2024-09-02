# frozen_string_literal: true

RSpec.describe RubyUnits::String do
  describe "Unit creation from strings" do
    specify { expect("1 mm".to_unit).to have_attributes(scalar: 1, units: "mm", kind: :length) }
    specify { expect("1 mm".to_unit("ft")).to have_attributes(scalar: 5/1524r, units: "ft", kind: :length) }

    specify { expect("1 m".convert_to("ft")).to be_within(RubyUnits::Unit.new("0.01 ft")).of RubyUnits::Unit.new("3.28084 ft") }
  end

  describe "% (format)S" do
    subject(:unit) { RubyUnits::Unit.new("1.23456 m/s^2") }

    specify { expect("%0.2f" % 1.23).to eq("1.23") }
    specify { expect("" % unit).to eq("") }
    specify { expect("%0.2f" % unit).to eq("1.23 m/s^2") }
    specify { expect("%0.2f km/h^2" % unit).to eq("15999.90 km/h^2") }
    specify { expect("km/h^2" % unit).to eq("15999.9 km/h^2") }
    specify { expect("%H:%M:%S" % RubyUnits::Unit.new("1.5 h")).to eq("01:30:00") }
  end
end
