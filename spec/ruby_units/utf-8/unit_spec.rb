# frozen_string_literal: true

require File.dirname(__FILE__) + "/../../spec_helper"

describe Unit, "Degrees" do
  context "when the UTF-8 symbol is used" do
    context "Angles" do
      it "is a degree" do
        expect(RubyUnits::Unit.new("180\u00B0").units).to eq("deg")
      end
    end

    context "Temperature" do
      it "is a degree Celcius" do
        expect(RubyUnits::Unit.new("180\u00B0C").units).to eq("degC")
      end

      it "is a degree Fahrenheit" do
        expect(RubyUnits::Unit.new("180\u00B0F").units).to eq("degF")
      end
    end
  end
end
