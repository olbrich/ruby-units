require 'spec_helper'

describe RubyUnits::Configuration do
  context '.separator is true' do
    it 'has a space between the scalar and the unit' do
      expect(RubyUnits::Unit.new('1 m').to_s).to eq '1 m'
    end
  end

  context '.separator is false' do
    around(:each) do |example|
      RubyUnits.configure do |config|
        config.separator = false
      end
      example.run
      RubyUnits.reset
    end

    it 'does not have a space between the scalar and the unit' do
      expect(RubyUnits::Unit.new('1 m').to_s).to eq '1m'
      expect(RubyUnits::Unit.new('14.5 lbs').to_s(:lbs)).to eq '14lbs, 8oz'
      expect(RubyUnits::Unit.new('220 lbs').to_s(:stone)).to eq '15stone, 10lb'
      expect(RubyUnits::Unit.new('14.2 ft').to_s(:ft)).to eq %(14'2")
      expect(RubyUnits::Unit.new('1/2 cup').to_s).to eq '1/2cu'
      expect(RubyUnits::Unit.new('123.55 lbs').to_s('%0.2f')).to eq '123.55lbs'
    end
  end
end
