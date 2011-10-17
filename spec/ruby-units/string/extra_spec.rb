require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/../../../lib/ruby_units/string/extra'
describe String do
  context "Time syntax sugar" do
    before(:each) do
      Time.stub(:now).and_return(Time.at(1303656390))
      Date.stub(:today).and_return(Date.new(2011,4,1))
      DateTime.stub(:now).and_return(DateTime.new(2011,4,1,0,0,0))
    end

    specify { "5 min".ago.should be_instance_of Time }
  
    specify { "5 min".from(Time.now).should be_instance_of Time }
    specify { "5 min".from_now.should be_instance_of Time }
  
    specify { "5 min".after(Time.parse('12:00')).should be_instance_of Time }
  
    specify { "5 min".before.should be_instance_of Time}
    specify { "5 min".before(Time.now).should be_instance_of Time}
    specify { "5 min".before_now.should be_instance_of Time}
    specify { "5 min".before(Time.parse('12:00')).should be_instance_of Time}
  
    specify { "min".since.should be_instance_of Unit}
    specify { "min".since(Time.parse("12:00")).should be_instance_of Unit}
    specify { "min".since(Time.now - 60).should == Unit("1 min")}
    specify { "days".since(Date.today - 3).should == Unit("3 d")}
    specify { expect {"days".since(1000) }.to raise_error(ArgumentError, "Must specify a Time, Date, or DateTime")}
          
    specify { "min".until.should be_instance_of Unit}
    specify { "min".until(Time.parse("12:00")).should be_instance_of Unit}
    specify { "min".until(Time.now + 60).should == Unit("1 min")}
    specify { "days".until(Date.today + 3).should == Unit("3 d")}
    specify { expect {"days".until(1000) }.to raise_error(ArgumentError, "Must specify a Time, Date, or DateTime")}
  
    specify { "today".to_date.should be_instance_of Date }
    specify { "2011-4-1".to_date.should be_instance_of Date }
  
    specify { "now".to_datetime.should be_instance_of DateTime }
    specify { "now".to_time.should be_instance_of Time }
  
    specify { "10001-01-01 12:00".to_time.should be_instance_of Time }
    specify { "2001-01-01 12:00".to_time.should be_instance_of Time }
  
  end
end