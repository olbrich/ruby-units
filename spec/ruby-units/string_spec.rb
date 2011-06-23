require File.dirname(__FILE__) + '/../spec_helper'

describe String do
  context "Unit creation from strings" do
    specify { "1 mm".to_unit.should be_instance_of Unit }
    specify { "1 mm".unit.should be_instance_of Unit }
    specify { "1 mm".u.should be_instance_of Unit }
    specify { "1 m".to("ft").should be_within(Unit("0.01 ft")).of Unit("3.28084 ft") }
  end
  
  context "Time syntax sugar" do
    before(:each) do
      Time.stub(:now).and_return(Time.at(1303656390))
      Date.stub(:today).and_return(Date.new(2011,4,1))
      DateTime.stub(:now).and_return(DateTime.new(2011,4,1,0,0,0))
    end
    specify { "5 min".ago.should be_instance_of Time }
    
    specify { "5 min".from.should be_instance_of Time }
    specify { "5 min".from('now').should be_instance_of Time }
    specify { "5 min".from_now.should be_instance_of Time }
    
    specify { "5 min".after('12:00').should be_instance_of Time }
    
    specify { "5 min".before.should be_instance_of Time}
    specify { "5 min".before('now').should be_instance_of Time}
    specify { "5 min".before_now.should be_instance_of Time}
    specify { "5 min".before('12:00').should be_instance_of Time}
    
    specify { "min".since.should be_instance_of Unit}
    specify { "min".since("12:00").should be_instance_of Unit}
    specify { "min".since(Time.now - 60).should == Unit("1 min")}
    specify { "days".since(Date.today - 3).should == Unit("3 d")}
    specify { expect {"days".since(1000) }.to raise_error(ArgumentError, "Must specify a Time, DateTime, or String")}
            
    specify { "min".until.should be_instance_of Unit}
    specify { "min".until("12:00").should be_instance_of Unit}
    specify { "min".until(Time.now + 60).should == Unit("1 min")}
    specify { "days".until(Date.today + 3).should == Unit("3 d")}
    specify { expect {"days".until(1000) }.to raise_error(ArgumentError, "Must specify a Time, DateTime, or String")}
    
    specify { "today".to_date.should be_instance_of Date }
    specify { "2011-4-1".to_date.should be_instance_of Date }

    specify { "now".to_datetime.should be_instance_of DateTime }
    specify { "now".to_time.should be_instance_of Time }
    
    specify { "10001-01-01 12:00".time.should be_instance_of Time }
    specify { "2001-01-01 12:00".time.should be_instance_of Time }
    
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