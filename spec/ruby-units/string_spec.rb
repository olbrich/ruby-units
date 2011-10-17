require File.dirname(__FILE__) + '/../spec_helper'

describe String do
  context "Unit creation from strings" do
    specify { "1 mm".to_unit.should be_instance_of Unit }
    specify { "1 mm".unit.should be_instance_of Unit }
    specify { "1 mm".u.should be_instance_of Unit }
    specify { "1 m".convert_to("ft").should be_within(Unit("0.01 ft")).of Unit("3.28084 ft") }
  end
  
  context "output format" do
    subject { Unit("1.23456 m/s^2") }
    specify { ("" % subject).should == ""}
    specify { ("%0.2f" % subject).should == "1.23 m/s^2"}
    specify { ("%0.2f km/h^2" % subject).should == "15999.90 km/h^2"}
    specify { ("km/h^2" % subject).should == "15999.9 km/h^2"}
    specify { ("%H:%M:%S" % Unit("1.5 h")).should == "01:30:00"}
  end
  
end