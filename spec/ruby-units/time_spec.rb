require File.dirname(__FILE__) + '/../spec_helper'

describe Time do
  let(:now) { Time.at(1303656390) }
  before(:each) do
    Time.stub(:now).and_return(now)
  end

  context ".at" do
    subject { Date.new(2011,4,1).to_unit }
    specify { Time.at(Time.at(0)).utc.strftime("%D %T").should == "01/01/70 00:00:00" }
    specify { Time.at(subject - Date.new(1970,1,1)).getutc.strftime("%D %T").should == "04/01/11 00:00:00"}
    specify { Time.at(subject - Date.new(1970,1,1), 500).usec.should == 500}
  end

  context ".in" do
    specify { Time.in("5 min").should be_a Time}
    specify { Time.in("5 min").should > Time.now}
  end

  context '#to_date' do
    subject { Time.parse("2012-01-31 11:59:59") }
    specify { subject.to_date.to_s.should == "2012-01-31" }
    specify { (subject+1).to_date.to_s.should == "2012-01-31" }
  end

  context '#to_unit' do
    subject { now }
    its(:to_unit)         { should be_an_instance_of(Unit) }
    its('to_unit.units')  { should == "s" }
    specify               { subject.to_unit('h').kind.should == :time}
    specify               { subject.to_unit('h').units.should == 'h'}
  end

  context 'addition (+)' do
    specify { (Time.now + 1).should == Time.at(1303656390 + 1)}
    specify { (Time.now + Unit("10 min")).should == Time.at(1303656390 + 600)}
  end

  context 'subtraction (-)' do
    specify { (Time.now - 1).should == Time.at(1303656390 - 1)}
    specify { (Time.now - Unit("10 min")).should == Time.at(1303656390 - 600)}
    specify { (Time.now - Unit("150 years")).should == Time.parse("1861-04-24 09:46:30 -0500")}
  end

end
