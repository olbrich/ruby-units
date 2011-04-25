require File.dirname(__FILE__) + '/../spec_helper'

describe Time do
  before(:each) do
    Time.stub(:now).and_return(Time.at(1303656390))
  end

  context ".at" do
    subject { Date.new(2011,4,1).to_unit }
    specify { Time.at(subject - Date.new(1970,1,1)).strftime("%D %T").should == "03/31/11 20:00:00"}
  end
  
  context ".in" do
    specify { Time.in("5 min").should be_a Time}
    specify { Time.in("5 min").should > Time.now}
  end
  
  context 'addition (+)' do
    specify { (Time.now + 1).should == Time.at(1303656390 + 1)}
    specify { (Time.now + Unit("10 min")).should == Time.at(1303656390 + 600)}
  end

  context 'subtraction (-)' do
    specify { (Time.now - 1).should == Time.at(1303656390 - 1)}
    specify { (Time.now - Unit("10 min")).should == Time.at(1303656390 - 600)}
  end

end