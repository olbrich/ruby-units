# frozen_string_literal: true

require 'spec_helper'

describe RubyUnits::Configuration do
  describe '.separator' do
    context 'when set to true' do
      it 'has a space between the scalar and the unit' do
        expect(RubyUnits::Unit.new('1 m').to_s).to eq '1 m'
      end
    end

    context 'when set to false' do
      around do |example|
        RubyUnits.configure do |config|
          config.separator = false
        end
        example.run
        RubyUnits.reset
      end

      it 'does not have a space between the scalar and the unit' do
        expect(RubyUnits::Unit.new('1 m').to_s).to eq '1m'
        expect(RubyUnits::Unit.new('14.5 lbs').to_s(:lbs)).to eq '14lbs 8oz'
        expect(RubyUnits::Unit.new('220 lbs').to_s(:stone)).to eq '15stone 10lbs'
        expect(RubyUnits::Unit.new('14.2 ft').to_s(:ft)).to eq %(14'2-2/5")
        expect(RubyUnits::Unit.new('1/2 cup').to_s).to eq '1/2cu'
        expect(RubyUnits::Unit.new('123.55 lbs').to_s('%0.2f')).to eq '123.55lbs'
      end
    end
  end

  describe '.format' do
    context 'when set to :rational' do
      it 'uses rational notation' do
        expect(RubyUnits::Unit.new('1 m/s^2').to_s).to eq '1 m/s^2'
      end
    end

    context 'when set to :exponential' do
      around do |example|
        RubyUnits.configure do |config|
          config.format = :exponential
        end
        example.run
        RubyUnits.reset
      end

      it 'uses exponential notation' do
        expect(RubyUnits::Unit.new('1 m/s^2').to_s).to eq '1 m*s^-2'
      end
    end
  end
end
