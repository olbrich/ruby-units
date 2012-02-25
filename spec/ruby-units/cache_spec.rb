require File.dirname(__FILE__) + '/../spec_helper'

describe Unit::Cache do
  subject { Unit::Cache }
  let(:unit) { Unit('1 m') }

  before(:each) do
    subject.clear
    subject.set("m", unit)
  end

  context ".clear" do    
    it "should clear the cache" do
      subject.clear
      subject.get('m').should be_nil
    end
  end

  context ".get" do
    it "should retrieve values already in the cache" do
      subject.get['m'].should == unit
    end
  end

  context ".set" do
    it "should put a unit into the cache" do
      subject.set('kg', Unit('1 kg'))
      subject.get['kg'].should == Unit('1 kg')
    end
  end
end