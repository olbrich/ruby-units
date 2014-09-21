require_relative "spec_helper"

describe Date do
  subject { Date.new(2011,4,1) }
  
  it {is_expected.to be_instance_of Date}
  it {is_expected.to respond_to :to_unit}
  it {is_expected.to respond_to :to_time}
  it {is_expected.to respond_to :to_date}  
  
  specify { expect(subject + "5 days".unit).to eq(Date.new(2011,4,6)) }
  specify { expect(subject - "5 days".unit).to eq(Date.new(2011,3,27)) }
  # 2012 is a leap year...
  specify { expect(subject + "1 year".unit).to eq(Date.new(2012,3,31)) }
  specify { expect(subject - "1 year".unit).to eq(Date.new(2010,4,1)) }
end

describe "Date Unit" do

  subject { Date.new(2011,4,1).to_unit }

  it { is_expected.to be_instance_of Unit }
  its(:scalar) { should be_kind_of Rational }
  its(:units) { should == "d" }
  its(:kind) { should == :time }

  specify { expect(subject + "5 days".unit).to eq(Date.new(2011,4,6)) }
  specify { expect(subject - "5 days".unit).to eq(Date.new(2011,3,27)) }

  specify { expect { subject + Date.new(2011,4,1) }.to raise_error(ArgumentError) }
  specify { expect { subject + DateTime.new(2011,4,1,12,00,00) }.to raise_error(ArgumentError) }
  specify { expect { subject + Time.parse("2011-04-01 12:00:00") }.to raise_error(ArgumentError) }

  specify { expect(subject - Date.new(2011,4,1)).to be_zero }
  specify { expect(subject - DateTime.new(2011,4,1,00,00,00)).to be_zero }
  specify { expect {(subject - Time.parse("2011-04-01 00:00"))}.to raise_error(ArgumentError) }
  specify { expect(Date.new(2011,4,1) + 1).to eq(Date.new(2011,4,2))}
end
