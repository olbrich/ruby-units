# frozen_string_literal: true

RSpec.describe "initialization" do
  describe "Hash parameter validation" do
    context "with invalid scalar" do
      it "raises ArgumentError when scalar is not numeric" do
        expect { RubyUnits::Unit.new(scalar: "invalid", numerator: ["<meter>"], denominator: ["<second>"]) }
          .to raise_error(ArgumentError, ":scalar must be numeric")
      end

      it "raises ArgumentError when scalar is nil" do
        expect { RubyUnits::Unit.new(scalar: nil, numerator: ["<meter>"], denominator: ["<second>"]) }
          .to raise_error(ArgumentError, ":scalar must be numeric")
      end

      it "raises ArgumentError when scalar is an array" do
        expect { RubyUnits::Unit.new(scalar: [1, 2], numerator: ["<meter>"], denominator: ["<second>"]) }
          .to raise_error(ArgumentError, ":scalar must be numeric")
      end
    end

    context "with invalid numerator" do
      it "raises ArgumentError when numerator is not an array" do
        expect { RubyUnits::Unit.new(scalar: 1, numerator: "<meter>", denominator: ["<second>"]) }
          .to raise_error(ArgumentError, ":numerator must be an Array<String>")
      end

      it "raises ArgumentError when numerator contains non-strings" do
        expect { RubyUnits::Unit.new(scalar: 1, numerator: ["<meter>", 123], denominator: ["<second>"]) }
          .to raise_error(ArgumentError, ":numerator must be an Array<String>")
      end

      it "raises ArgumentError when numerator is nil" do
        expect { RubyUnits::Unit.new(scalar: 1, numerator: nil, denominator: ["<second>"]) }
          .to raise_error(ArgumentError, ":numerator must be an Array<String>")
      end
    end

    context "with invalid denominator" do
      it "raises ArgumentError when denominator is not an array" do
        expect { RubyUnits::Unit.new(scalar: 1, numerator: ["<meter>"], denominator: "<second>") }
          .to raise_error(ArgumentError, ":denominator must be an Array<String>")
      end

      it "raises ArgumentError when denominator contains non-strings" do
        expect { RubyUnits::Unit.new(scalar: 1, numerator: ["<meter>"], denominator: [123, "<second>"]) }
          .to raise_error(ArgumentError, ":denominator must be an Array<String>")
      end

      it "raises ArgumentError when denominator is nil" do
        expect { RubyUnits::Unit.new(scalar: 1, numerator: ["<meter>"], denominator: nil) }
          .to raise_error(ArgumentError, ":denominator must be an Array<String>")
      end
    end

    context "with invalid signature" do
      it "raises ArgumentError when signature is not an integer" do
        expect { RubyUnits::Unit.new(scalar: 1, numerator: ["<meter>"], denominator: ["<second>"], signature: "invalid") }
          .to raise_error(ArgumentError, ":signature must be an Integer")
      end

      it "raises ArgumentError when signature is a float" do
        expect { RubyUnits::Unit.new(scalar: 1, numerator: ["<meter>"], denominator: ["<second>"], signature: 1.5) }
          .to raise_error(ArgumentError, ":signature must be an Integer")
      end

      it "accepts nil signature" do
        expect { RubyUnits::Unit.new(scalar: 1, numerator: ["<meter>"], denominator: ["<second>"], signature: nil) }
          .not_to raise_error
      end

      it "accepts integer signature" do
        expect { RubyUnits::Unit.new(scalar: 1, numerator: ["<meter>"], denominator: ["<second>"], signature: 123) }
          .not_to raise_error
      end
    end

    context "with valid hash parameters" do
      it "creates unit with all parameters" do
        unit = RubyUnits::Unit.new(scalar: 2, numerator: ["<meter>"], denominator: ["<second>"], signature: nil)
        expect(unit.scalar).to eq(2)
        expect(unit.units).to eq("m/s")
      end

      it "uses default scalar of 1 when not provided" do
        unit = RubyUnits::Unit.new(numerator: ["<meter>"], denominator: ["<second>"])
        expect(unit.scalar).to eq(1)
      end

      it "uses UNITY_ARRAY for numerator when not provided" do
        unit = RubyUnits::Unit.new(scalar: 5, denominator: ["<second>"])
        expect(unit.numerator).to eq(["<1>"])
      end

      it "uses UNITY_ARRAY for denominator when not provided" do
        unit = RubyUnits::Unit.new(scalar: 5, numerator: ["<meter>"])
        expect(unit.denominator).to eq(["<1>"])
      end
    end
  end

  describe "Array argument handling" do
    context "with arrays containing different argument types" do
      it "handles array with single Unit" do
        original = RubyUnits::Unit.new("5 m")
        unit = RubyUnits::Unit.new([original])
        expect(unit.scalar).to eq(5)
        expect(unit.units).to eq("m")
      end

      it "handles array with scalar and unit string" do
        unit = RubyUnits::Unit.new([3, "m"])
        expect(unit.scalar).to eq(3)
        expect(unit.units).to eq("m")
      end

      it "handles array with scalar, numerator array, and denominator array" do
        unit = RubyUnits::Unit.new([2, ["<meter>"], ["<second>"]])
        expect(unit.scalar).to eq(2)
        expect(unit.units).to eq("m/s")
      end

      it "handles array with scalar, numerator string, and denominator string" do
        unit = RubyUnits::Unit.new([2, "m^2", "s^2"])
        expect(unit.scalar).to eq(2)
        expect(unit.units).to eq("m^2/s^2")
      end

      it "raises error for array with nil first element" do
        expect { RubyUnits::Unit.new([nil, "m"]) }
          .to raise_error(ArgumentError, "Invalid Unit Format")
      end
    end
  end

  describe "special_format_regex" do
    it "matches temperature units" do
      expect(RubyUnits::Unit.special_format_regex).to match("tempK")
      expect(RubyUnits::Unit.special_format_regex).to match("tempF")
    end

    it "matches stone-pound format" do
      expect(RubyUnits::Unit.special_format_regex).to match("st 5 lbs")
    end

    it "matches pound-ounce format" do
      expect(RubyUnits::Unit.special_format_regex).to match("lbs 5 oz")
    end

    it "matches feet-inch format" do
      expect(RubyUnits::Unit.special_format_regex).to match("ft 5 in")
    end

    it "matches percentage" do
      expect(RubyUnits::Unit.special_format_regex).to match("%")
    end

    it "matches time format" do
      expect(RubyUnits::Unit.special_format_regex).to match("12:34:56")
    end

    it "matches complex numbers with units" do
      expect(RubyUnits::Unit.special_format_regex).to match("i m")
    end

    it "matches plus-minus format" do
      expect(RubyUnits::Unit.special_format_regex).to match("&plusmn;")
      expect(RubyUnits::Unit.special_format_regex).to match("+/-")
    end

    it "matches division with number" do
      expect(RubyUnits::Unit.special_format_regex).to match("m/5.5")
    end

    it "does not match regular units" do
      expect(RubyUnits::Unit.special_format_regex).not_to match("m")
      expect(RubyUnits::Unit.special_format_regex).not_to match("kg")
      expect(RubyUnits::Unit.special_format_regex).not_to match("m/s")
    end
  end

  describe "nil argument handling" do
    it "raises ArgumentError for nil as single argument" do
      expect { RubyUnits::Unit.new(nil) }
        .to raise_error(ArgumentError, "Invalid Unit Format")
    end
  end

  describe "three-argument initialization with arrays" do
    it "converts array numerator to string" do
      unit = RubyUnits::Unit.new(2, ["<meter>", "<meter>"], ["<second>"])
      expect(unit.units).to eq("m^2/s")
    end

    it "converts array denominator to string" do
      unit = RubyUnits::Unit.new(2, ["<meter>"], ["<second>", "<second>"])
      expect(unit.units).to eq("m/s^2")
    end

    it "handles both numerator and denominator as arrays" do
      unit = RubyUnits::Unit.new(1, ["<kilogram>", "<meter>"], ["<second>", "<second>"])
      expect(unit.units).to eq("kg*m/s^2")
    end
  end

  describe "caching behavior" do
    before do
      # Clear cache before each test
      RubyUnits::Unit.clear_cache
    end

    it "caches regular unit strings" do
      RubyUnits::Unit.new("1 m")
      expect(RubyUnits::Unit.cached.keys).to include("m")
    end

    it "does not cache temperature units" do
      RubyUnits::Unit.new("100 tempK")
      expect(RubyUnits::Unit.cached.keys.any? { |k| k =~ /temp/ }).to be false
    end

    it "does not cache special format units" do
      RubyUnits::Unit.new("5%")
      expect(RubyUnits::Unit.cached.keys).not_to include("%")
    end

    it "caches unary units when scalar is 1" do
      unit = RubyUnits::Unit.new("1 m/s")
      expect(RubyUnits::Unit.cached.get("m/s")).to eq(unit)
    end

    it "caches unit definition when scalar is not 1" do
      RubyUnits::Unit.new("5 m/s")
      cached = RubyUnits::Unit.cached.get("m/s")
      expect(cached).not_to be_nil
      expect(cached.scalar).to eq(1)
    end
  end

  describe "edge cases in initialization" do
    it "handles nested array initialization" do
      inner_array = [5, "m"]
      unit = RubyUnits::Unit.new(inner_array)
      expect(unit.scalar).to eq(5)
      expect(unit.units).to eq("m")
    end

    it "handles Unit copy through single argument" do
      original = RubyUnits::Unit.new("10 kg")
      copy = RubyUnits::Unit.new(original)
      expect(copy.scalar).to eq(10)
      expect(copy.units).to eq("kg")
      expect(copy).not_to be(original) # Different object
    end

    it "freezes instance variables after initialization" do
      unit = RubyUnits::Unit.new("5 m")
      expect(unit.scalar).to be_frozen
      expect(unit.numerator).to be_frozen
      expect(unit.denominator).to be_frozen
      expect(unit.base_scalar).to be_frozen
    end
  end

  describe "two-argument initialization with caching" do
    before do
      RubyUnits::Unit.clear_cache
    end

    it "uses cached unit when available" do
      # Prime the cache
      RubyUnits::Unit.new("m")

      # This should use the cached version
      unit = RubyUnits::Unit.new(5, "m")
      expect(unit.scalar).to eq(5)
      expect(unit.units).to eq("m")
    end

    it "parses when unit not in cache" do
      # Clear cache to ensure it's not cached
      RubyUnits::Unit.clear_cache

      unit = RubyUnits::Unit.new(3, "kg*m/s^2")
      expect(unit.scalar).to eq(3)
      expect(unit.units).to eq("kg*m/s^2")
    end
  end

  describe "three-argument initialization with caching" do
    before do
      RubyUnits::Unit.clear_cache
    end

    it "uses cached unit when available" do
      # Prime the cache
      RubyUnits::Unit.new("m/s")

      # This should use the cached version
      unit = RubyUnits::Unit.new(10, "m", "s")
      expect(unit.scalar).to eq(10)
      expect(unit.units).to eq("m/s")
    end

    it "parses when unit not in cache" do
      RubyUnits::Unit.clear_cache

      unit = RubyUnits::Unit.new(2, "m^2", "s^2")
      expect(unit.scalar).to eq(2)
      expect(unit.units).to eq("m^2/s^2")
    end
  end
end
