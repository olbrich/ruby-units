require File.dirname(__FILE__) + '/../spec_helper'

describe Date do
  subject { Date.new(2011,4,1) }
  
  it {should be_instance_of Date}
  it {should respond_to :to_unit}
  it {should respond_to :to_time}
  it {should respond_to :to_date}  
  
  specify { (subject + "5 days".unit).should == Date.new(2011,4,6) }
  specify { (subject - "5 days".unit).should == Date.new(2011,3,27) }
  # 2012 is a leap year...
  specify { (subject + "1 year".unit).should == Date.new(2012,3,31) }
  specify { (subject - "1 year".unit).should == Date.new(2010,4,1) }
end

describe "Date Unit" do

  subject { Date.new(2011,4,1).to_unit }

  it { should be_instance_of Unit }
  its(:scalar) { should be_kind_of Rational }
  its(:units) { should == "d" }
  its(:kind) { should == :time }

  specify { (subject + "5 days".unit).should == Date.new(2011,4,6) }
  specify { (subject - "5 days".unit).should == Date.new(2011,3,27) }

  specify { expect { subject + Date.new(2011,4,1) }.to raise_error(ArgumentError) }
  specify { expect { subject + DateTime.new(2011,4,1,12,00,00) }.to raise_error(ArgumentError) }
  specify { expect { subject + Time.parse("2011-04-01 12:00:00") }.to raise_error(ArgumentError) }

  specify { (subject - Date.new(2011,4,1)).should be_zero }
  specify { (subject - DateTime.new(2011,4,1,00,00,00)).should be_zero }
  specify { expect {(subject - Time.parse("2011-04-01 00:00"))}.to raise_error(ArgumentError) }
  specify { (Date.new(2011,4,1) + 1).should == Date.new(2011,4,2)}
end