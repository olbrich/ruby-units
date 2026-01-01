# frozen_string_literal: true

require "spec_helper"

describe RubyUnits::Configuration do
  describe "#initialize" do
    it "accepts keyword arguments for separator and format" do
      config = described_class.new(separator: :none, format: :exponential)
      expect(config.separator).to be_nil
      expect(config.format).to eq :exponential
    end

    it "uses default values when no arguments are provided" do
      config = described_class.new
      expect(config.separator).to eq " "
      expect(config.format).to eq :rational
    end

    it "validates separator value" do
      expect { described_class.new(separator: "invalid") }.to raise_error(ArgumentError)
    end

    it "accepts deprecated boolean separator values with warning" do
      expect { described_class.new(separator: true) }.to output(/DEPRECATION WARNING.*boolean/).to_stderr
      expect { described_class.new(separator: false) }.to output(/DEPRECATION WARNING.*boolean/).to_stderr
    end

    it "converts deprecated boolean values correctly" do
      expect(described_class.new(separator: true).separator).to eq " "
      expect(described_class.new(separator: false).separator).to be_nil
    end

    it "validates format value" do
      expect { described_class.new(format: :invalid) }.to raise_error(ArgumentError)
    end
  end

  describe "#use_bigdecimal" do
    it "validates boolean value" do
      expect { described_class.new(use_bigdecimal: :maybe) }.to raise_error(ArgumentError)
    end

    it "raises when enabling without requiring bigdecimal" do
      config = described_class.new
      hide_const("BigDecimal")
      expect { config.use_bigdecimal = true }.to raise_error(RubyUnits::MissingDependencyError, /require 'bigdecimal'/)
    end

    # NOTE: bigdecimal/util is required in spec_helper.rb for all specs,
    it "allows enabling when bigdecimal is required" do
      config = described_class.new
      config.use_bigdecimal = true
      expect(config.use_bigdecimal).to be true
    end
  end

  describe ".separator" do
    context "when set to :space" do
      around do |example|
        RubyUnits.reset
        RubyUnits.configure do |config|
          config.separator = :space
        end
        example.run
        RubyUnits.reset
      end

      it "has a space between the scalar and the unit" do
        expect(RubyUnits::Unit.new("1 m").to_s).to eq "1 m"
      end
    end

    context "when set to :none" do
      around do |example|
        RubyUnits.configure do |config|
          config.separator = :none
        end
        example.run
        RubyUnits.reset
      end

      it "does not have a space between the scalar and the unit" do
        expect(RubyUnits::Unit.new("1 m").to_s).to eq "1m"
        expect(RubyUnits::Unit.new("14.5 lbs").to_s(:lbs)).to eq "14lbs 8oz"
        expect(RubyUnits::Unit.new("220 lbs").to_s(:stone)).to eq "15stone 10lbs"
        expect(RubyUnits::Unit.new("14.2 ft").to_s(:ft)).to eq %(14'2-2/5")
        expect(RubyUnits::Unit.new("1/2 cup").to_s).to eq "1/2cu"
        expect(RubyUnits::Unit.new("123.55 lbs").to_s("%0.2f")).to eq "123.55lbs"
      end
    end

    context "when set to false (deprecated)" do
      around do |example|
        RubyUnits.configure do |config|
          config.separator = false
        end
        example.run
        RubyUnits.reset
      end

      it "issues a deprecation warning" do
        expect do
          RubyUnits.configure do |config|
            config.separator = false
          end
        end.to output(/DEPRECATION WARNING.*boolean/).to_stderr
      end

      it "works like :none for backward compatibility" do
        expect(RubyUnits::Unit.new("1 m").to_s).to eq "1m"
      end
    end
  end

  describe ".format" do
    context "when set to :rational" do
      around do |example|
        RubyUnits.reset
        RubyUnits.configure do |config|
          config.format = :rational
        end
        example.run
        RubyUnits.reset
      end

      it "uses rational notation" do
        expect(RubyUnits::Unit.new("1 m/s^2").to_s).to eq "1 m/s^2"
      end
    end

    context "when set to :exponential" do
      around do |example|
        RubyUnits.configure do |config|
          config.format = :exponential
        end
        example.run
        RubyUnits.reset
      end

      it "uses exponential notation" do
        expect(RubyUnits::Unit.new("1 m/s^2").to_s).to eq "1 m*s^-2"
      end
    end
  end
end
