require File.dirname(__FILE__) + '/../spec_helper'

describe Math do
  context "with '1 mm^6'" do
    subject { '1 mm^6'.to_unit }
    
    specify { Math.sqrt(subject).should == '1 mm^3'.to_unit }
    specify { Math.sqrt(4).should == 2 }
    
    if RUBY_VERSION > "1.9"
      # cbrt is only defined in Ruby > 1.9
      specify { Math.cbrt(subject).should == '1 mm^2'.to_unit }
      specify { Math.cbrt(8).should == 2 }
    end

  end
  
  context "Trigonometry functions" do
    
    context "with '45 deg' unit" do
      subject { "45 deg".unit }
      specify { Math.sin(subject).should be_within(0.01).of(0.70710678) }
      specify { Math.cos(subject).should be_within(0.01).of(0.70710678) }
      specify { Math.tan(subject).should be_within(0.01).of(1) }
      specify { Math.sinh(subject).should be_within(0.01).of(0.8686709614860095) }
      specify { Math.cosh(subject).should be_within(0.01).of(1.3246090892520057) }
      specify { Math.tanh(subject).should be_within(0.01).of(0.6557942026326724) }
    end

    context "with 'PI/4 radians' unit" do
      subject { (Math::PI/4).unit('radians') }
      specify { Math.sin(subject).should be_within(0.01).of(0.70710678) }
      specify { Math.cos(subject).should be_within(0.01).of(0.70710678) }
      specify { Math.tan(subject).should be_within(0.01).of(1) }
      specify { Math.sinh(subject).should be_within(0.01).of(0.8686709614860095) }
      specify { Math.cosh(subject).should be_within(0.01).of(1.3246090892520057) }
      specify { Math.tanh(subject).should be_within(0.01).of(0.6557942026326724) }
    end

    context "with 'PI/4' continues to work" do
      subject { (Math::PI/4) }
      specify { Math.sin(subject).should be_within(0.01).of(0.70710678) }
      specify { Math.cos(subject).should be_within(0.01).of(0.70710678) }
      specify { Math.tan(subject).should be_within(0.01).of(1) }
      specify { Math.sinh(subject).should be_within(0.01).of(0.8686709614860095) }
      specify { Math.cosh(subject).should be_within(0.01).of(1.3246090892520057) }
      specify { Math.tanh(subject).should be_within(0.01).of(0.6557942026326724) }
    end

    specify { Math.hypot("1 m".unit, "2 m".unit).should be_within("0.01 m".unit).of("2.23607 m".unit) }
    specify { Math.hypot("1 m".unit, "2 ft".unit).should be_within("0.01 m".unit).of("1.17116 m".unit) }
    specify { expect {Math.hypot("1 m".unit, "2 lbs".unit) }.to raise_error(ArgumentError) }
    
    specify { Math.atan2("1 m".unit, "2 m".unit).should be_within(0.01).of(0.4636476090008061) }
    specify { Math.atan2("1 m".unit, "2 ft".unit).should be_within(0.01).of(1.0233478888629426) }
    specify { Math.atan2(1,1).should be_within(0.01).of(0.785398163397448)}
    specify { expect {Math.atan2("1 m".unit, "2 lbs".unit)}.to raise_error(ArgumentError) }
    
  end
  
  
  
end