require File.dirname(__FILE__) + '/../spec_helper'

describe Math do
  context "with '1 mm^6'" do
    subject { '1 mm^6'.to_unit }
    
    specify { Math.sqrt(subject).should == '1 mm^3'.to_unit }
  end
  
  
end