require_relative "spec_helper"

module RubyUnits

  describe "Unit::Definition('eV')" do
    subject {
      Unit::Definition.new("eV") do |ev|
        ev.aliases      = ["eV", "electron-volt"]
        ev.definition   = Unit.new("1.602E-19 joule")
        ev.display_name = "electron-volt"
      end
    }
    
    its(:name)          {should == "<eV>"}
    its(:aliases)       {should == %w{eV electron-volt}}
    its(:scalar)        {should == 1.602E-19}
    its(:numerator)     {should include("<kilogram>", "<meter>", "<meter>")}
    its(:denominator)   {should include("<second>", "<second>")}
    its(:display_name)  {should == "electron-volt"}
  end

end
