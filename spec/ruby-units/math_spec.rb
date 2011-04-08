require File.dirname(__FILE__) + '/../spec_helper'

describe Math do
  context "with '1 mm^6'" do
    subject { '1 mm^6'.to_unit }
    
    specify { Math.sqrt(subject).should == '1 mm^3'.to_unit }

    if RUBY_VERSION > "1.9"
      # cbrt is only defined in Ruby > 1.9
      specify { Math.cbrt(subject).should == '1 mm^2'.to_unit }
    end

  end
  
  context "Trigonometry functions" do
    
    context "with '90 deg' unit" do
      subject { "45 deg".unit }
      specify { Math.sin(subject).should be_within(0.01).of(0.70710678) }
      specify { Math.cos(subject).should be_within(0.01).of(0.70710678) }
      specify { Math.tan(subject).should be_within(0.01).of(1) }
      specify { Math.sinh(subject).should be_within(0.01).of(0.8686709614860095) }
      specify { Math.cosh(subject).should be_within(0.01).of(1.3246090892520057) }
      specify { Math.tanh(subject).should be_within(0.01).of(0.6557942026326724) }
    end
    
  end
  
  
end