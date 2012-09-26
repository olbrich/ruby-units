# encoding: utf-8

require File.dirname(__FILE__) + '/../../spec_helper'
    
if RUBY_VERSION.include?('1.9')
  describe Unit, 'Degrees' do
    context 'when the UTF-8 symbol is used' do
      context 'Angles' do
        it 'should be a degree' do
          Unit("180°").units.should == 'deg'
        end
      end

      context 'Temperature' do
        it 'should be a degree Celcius' do
          Unit("180°C").units.should == 'degC'
        end

        it 'should be a degree Fahrenheit' do
          Unit("180°F").units.should == 'degF'
        end
      end
    end
  end
end
