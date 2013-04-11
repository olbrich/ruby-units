require File.dirname(__FILE__) + '/../spec_helper'

# Complex numbers are a bit strange
# Technically you can't really compare them using <=>, and ruby 1.9 does not implement this method for them
# so it stands to reason that complex units should also not support :> or :<

describe Complex do
  subject { Complex(1,1) }
  it { should respond_to :to_unit }
end if defined?(Complex)

describe "Complex Unit" do
  subject { Complex(1.0, -1.0).to_unit }
  
  it { should be_instance_of Unit}
  it(:scalar) { should be_kind_of Complex }

  it { should == "1-1i".to_unit }
  it { should === "1-1i".to_unit }

  if RUBY_VERSION < "1.9"
    context "in Ruby < 1.9" do
      it "is comparable" do
        subject.should > "1+0.5i".to_unit
        subject.should < "2+1i".to_unit
      end
    end
  else
    context "in Ruby >= 1.9" do
      it "is not comparable" do 
        expect { subject > "1+1i".to_unit }.to raise_error(NoMethodError)
        expect { subject < "1+1i".to_unit }.to raise_error(NoMethodError) 
      end
    end
  end
  
end if defined?(Complex)
