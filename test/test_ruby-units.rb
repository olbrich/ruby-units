require 'rubygems'
require 'test/unit'
require 'ruby-units'
require 'yaml'
begin
	require 'chronic'
rescue LoadError
	warn "Can't test Chronic integration unless gem 'chronic' is installed"
end
begin 
	require 'uncertain'
rescue LoadError
	warn "Can't test Uncertain Units unless 'Uncertain' gem is installed"
end


class Unit < Numeric
  @@USER_DEFINITIONS = {'<inchworm>' =>  [%w{inworm inchworm}, 0.0254, :length, %w{<meter>} ],
                        '<habenero>'   => [%w{degH}, 100, :temperature, %w{<celsius>}]}
  Unit.setup
end

class Time
  @@forced_now = nil
  @@forced_gmt = nil
  class << self
    alias :unforced_now :now
    def forced_now
      @@forced_now.nil? ? unforced_now : @@forced_now
    end
    alias :now :forced_now
    
    def forced_now=(now)
      @@forced_now = now
    end
  end
    
  alias :unforced_gmt :gmt_offset
  def forced_gmt
    @@forced_gmt.nil? ? unforced_gmt : @@forced_gmt
  end
  alias :gmt_offset :forced_gmt

  def forced_gmt=(gmt)
    @@forced_gmt = now
  end
    
end

class DateTime
  @@forced_now = nil
  class << self
    alias :unforced_now :now
    def forced_now
      return @@forced_now ? @@forced_now : unforced_now
    end
    alias :now :forced_now
    
    def forced_now=(now)
      @@forced_now = now
    end
    
  end
end

class Dummy
  def to_unit
    '1 mm'.unit
  end
end

class TestRubyUnits < Test::Unit::TestCase
 
  def setup
    @april_fools = Time.at 1143910800
    @april_fools_datetime = DateTime.parse('2006-04-01T12:00:00-05:00')
    Time.forced_now = @april_fools
    DateTime.forced_now = @april_fools_datetime 
    #Unit.clear_cache
  end
  
  def teardown
    Time.forced_now = nil
    DateTime.forced_now = nil
  end
  
  def test_to_yaml
    unit = "1 mm".u
    assert_equal "--- !ruby/object:Unit \nscalar: 1\nnumerator: \n- <milli>\n- <meter>\ndenominator: \n- <1>\nsignature: 1\nbase_scalar: !ruby/object:Rational \n  denominator: 1000\n  numerator: 1\n", unit.to_yaml    
  end

  def test_time
    a = Time.now
    assert_equal "s", a.to_unit.units
    assert_equal a + 3600, a + "1 h".unit
    assert_equal a - 3600, a - "1 h".unit
    assert_in_delta Time.now - "1 h".unit, "1 h".ago, 1
    assert_in_delta Time.now + 3600, "1 h".from_now, 1
    assert_in_delta Time.now + "1 h".unit, "1 h".from_now, 1
    assert_in_delta Time.now - 3600, "1 h".before_now, 1
    assert_equal "60 min", "min".until(Time.now + 3600).to_s
    assert_equal "01:00", "min".since(Time.now - 3600).to_s("%H:%M")
    assert_in_delta Time.now, "now".time, 1
  end
  
	def test_from_now
		assert_equal "1 day".from_now, @april_fools + 86400
	end
	
	def test_from
		assert_equal "1 day".from("now"), @april_fools + 86400
	end

	def test_ago
		assert_equal "1 day".ago, @april_fools - 86400
	end
	
	def test_before_now
		assert_equal "1 day".before_now, @april_fools - 86400
	end
	
	def test_before
		assert_equal '1 days'.before('now'), @april_fools - 86400
	end

	def test_since
    assert_equal 'days'.since(@april_fools - 86400), "1 day".unit
    assert_equal 'days'.since('2006-3-31 12:00:00 -5:00'), "1 day".unit
    assert_equal 'days'.since(DateTime.parse('2006-3-31 12:00 -5:00')), "1 day".unit		
    assert_raises(ArgumentError) { 'days'.since(1) }
	end

	def test_until
    assert_equal 'days'.until('2006-04-2 12:00:00 -5:00'), '1 day'.unit		
    assert_raises(ArgumentError) { 'days'.until(1) }
	end

  def test_time_helpers
    assert_equal @april_fools, Time.now
    assert_equal @april_fools_datetime, DateTime.now
    assert_equal Time.now, 'now'.time
    assert_equal DateTime.now, 'now'.datetime
    assert_equal 1143910800, Unit.new(Time.now).scalar
    assert_equal @april_fools.unit.to_time, @april_fools
    assert_equal Time.in('1 day'), @april_fools + 86400
    assert_equal "2006-04-01T12:00:00-05:00", @april_fools_datetime.inspect
    assert_equal "2006-04-01T00:00:00+00:00", '2453826.5 days'.unit.to_datetime.to_s 
  end
  
  def test_string_helpers
    assert_equal '1 mm'.to('in'), Unit('1 mm').to('in')
  end

  [:sin, :cos, :tan, :sinh, :cosh, :tanh].each do |trig|
		define_method("test_#{trig}") do
			assert_equal Math.send(trig, Math::PI), Math.send(trig, "180 deg".unit)
		end
	end
	
  def test_clone
    unit1= "1 mm".unit
    unit2 = unit1.clone
    assert_not_equal unit1.numerator.object_id, unit2.numerator.object_id
    assert_not_equal unit1.denominator.object_id, unit2.denominator.object_id
    assert unit1 === unit2
  end 
  
  def test_unary_minus
    unit1 = Unit.new("1 mm^2")
    unit2 = Unit.new("-1 mm^2")
    assert_equal unit1, -unit2
  end
  
  def test_unary_plus
    unit1 = Unit.new("1 mm")
    assert_equal unit1, +unit1
  end

  def test_create_unit_only
    unit1 = Unit.new("m")
    assert_equal ['<meter>'], unit1.numerator
    assert_equal 1.0, unit1.scalar
  end
  
  def test_to_base
    unit1 = Unit.new("100 cm")
    assert_in_delta 1, unit1.to_base.scalar, 0.001
    unit2 = Unit("1 mm^2 ms^-2")
    assert_in_delta 1,  unit2.to_base.scalar, 0.001 
  end
  
  def test_to_unit
    unit1 = "1 mm".to_unit
    assert_equal unit1, unit1.to_unit
    assert Unit === unit1
    unit2 = Unit("1 mm")
    assert Unit === unit1
    assert unit1 == unit2
    unit1 = "2.54 cm".to_unit("in")
    assert_in_delta 1, unit1.scalar, 0.001 
    assert_equal ['<inch>'], unit1.numerator
    unit1 = "2.54 cm".unit("in")
    assert_in_delta 1, unit1.scalar, 0.001
    assert_equal ['<inch>'], unit1.numerator
    unit1 = 1.unit
    assert_in_delta 1, unit1.scalar, 0.001
    assert_equal ['<1>'], unit1.numerator
    unit1 = [1,'mm'].unit
    assert_in_delta 1, unit1.scalar, 0.001
    assert_equal ['<milli>','<meter>'], unit1.numerator
  end
  
  def test_create_unitless
    unit1 = Unit("1")
    assert_equal 1, unit1.to_f
    assert_equal ['<1>'],unit1.numerator
    assert_equal ['<1>'],unit1.denominator
    unit1 = Unit.new("1.5")
    assert_equal 1.5,unit1.to_f
    assert_equal ['<1>'],unit1.numerator
    assert_equal ['<1>'],unit1.denominator
  end
  
  def test_create_simple
    unit1 = Unit.new("1 m")
    assert_equal 1,unit1.scalar
    assert_equal ['<meter>'], unit1.numerator
    assert_equal ['<1>'],unit1.denominator
  end
  
  def test_create_compound
    unit1 = Unit.new("1 N*m")
    assert_equal 1,unit1.scalar 
    assert_equal ['<newton>','<meter>'],unit1.numerator
    assert_equal ['<1>'],unit1.denominator
  end
  
  def test_create_with_denominator
    unit1 = Unit.new("1 m/s")
    assert_equal 1, unit1.scalar
    assert_equal ['<meter>'],unit1.numerator
    assert_equal ['<second>'],unit1.denominator
  end
  
  def test_create_with_powers
    unit1 = Unit.new("1 m^2/s^2")
    assert_equal 1, unit1.scalar
    assert_equal ['<meter>','<meter>'],unit1.numerator
    assert_equal ['<second>','<second>'],unit1.denominator
    unit1 = Unit.new("1 m^2 kg^2 J^2/s^2")
    assert_equal 1, unit1.scalar
    assert_equal ['<meter>','<meter>','<kilogram>','<kilogram>','<joule>','<joule>'],unit1.numerator
    assert_equal ['<second>','<second>'],unit1.denominator
    
  end

  def test_create_with_zero_power
    unit1 = Unit.new("1 m^0")
    assert_equal 1,unit1.scalar
    assert_equal ['<1>'],unit1.numerator
    assert_equal ['<1>'],unit1.denominator
  end

  def test_create_with_negative_powers
    unit1 = Unit.new("1 m^2 s^-2")
    assert_equal 1, unit1.scalar
    assert_equal ['<meter>','<meter>'],unit1.numerator
    assert_equal ['<second>','<second>'],unit1.denominator
  end
  
  def test_create_from_array
    unit1 = Unit.new(1, "mm^2", "ul^2")
    assert_equal 1, unit1.scalar
    assert_equal ['<milli>','<meter>','<milli>','<meter>'], unit1.numerator
    assert_equal ['<micro>','<liter>','<micro>','<liter>'], unit1.denominator
  end
  
  def test_bad_create
    assert_raises(ArgumentError) { Unit.new(nil)}
    assert_raises(ArgumentError) { Unit.new(true)}
    assert_raises(ArgumentError) { Unit.new(false)}
    assert_raises(ArgumentError) { Unit.new(/(.+)/)}
  end
  
  def test_convert
    unit1 = Unit.new("1 attoparsec/microfortnight")
    assert_nothing_raised {
      unit2 = unit1 >> "in/s"
      assert_equal ['<inch>'],unit2.numerator
      assert_equal ['<second>'],unit2.denominator
      assert_in_delta 1.0043269330917,unit2.scalar,0.00001 
    }
  end
  
  def test_add_operator
    a = '0 mm'.unit
    b = '10 cm'.unit
    c = '1 in'.unit
    d = '1 ml'.unit
    
    assert_equal((a+b), b)
    assert_equal((a+b).units, b.units)
    assert_equal((b+a), b)
    assert_equal((b+a).units, b.units)
    assert_in_delta((b+c).scalar, 12.54, 0.01)
    assert_equal((b+c).units, 'cm')
    assert_raises(ArgumentError) {
      b + d
    }
  end
  
  def test_subtract_operator
    a = '0 mm'.unit
    b = '10 cm'.unit
    c = '1 in'.unit
    d = '1 ml'.unit
    
    assert_equal((a-b), -b)
    assert_equal((a-b).units, b.units)
    assert_equal((b-a), b)
    assert_equal((b-a).units, b.units)
    assert_in_delta((b-c).scalar, 7.46, 0.01)
    assert_equal((b-c).units, 'cm')
    assert_raises(ArgumentError) {
      b - d
    }
  end
  
  def test_convert_to
    unit1 = Unit.new("1 mm")
    unit2 = Unit.new("1 ft")
    assert_nothing_raised {
      unit3 = unit1 >> unit2
      assert_equal ['<foot>'], unit3.numerator
      assert_equal ['<1>'],unit3.denominator
      unit3 = unit1 >> "ft"
      assert_equal ['<foot>'], unit3.numerator
      assert_equal ['<1>'],unit3.denominator
    }
    assert_raises(ArgumentError) { unit1 >> 5.0}
    assert_equal unit1, unit1.to(true)
    assert_equal unit1, unit1.to(false)
    assert_equal unit1, unit1.to(nil)
  end
  
  def test_compare 
    unit1 = "1 mm".unit
    unit2 = "1 mm".unit
    unit3 = unit2 >> "in"
    assert unit1 === unit2
    assert !(unit1 === unit3)
    assert unit1 === "1 mm"
  end
  
  def test_matched_units
    unit1 = Unit.new("1 m*kg/s")
    unit2 = Unit.new("1 in*pound/min")
    assert unit1 =~ unit2
  end
  
  def test_matched_units_using_string
    unit1 = Unit.new("1 m*kg/s")
    assert unit1 =~ "in*pound/min"
  end
  
  def test_unmatched_units
    unit1 = Unit.new("1 m*kg/s")
    unit2 = Unit.new("1 mm")
    assert unit1 !~ unit2
  end
  
  def test_comparison_like_units
    unit1 = Unit.new("1 in")
    unit2 = Unit.new("1 mm")
    assert_nothing_raised {
      assert unit1 > unit2
    }
  end
  
  def test_comparison_unlike_units
    unit1 = Unit.new("1 kg")
    unit2 = Unit.new("1 mm")
    assert_raise(ArgumentError) { unit1 > unit2 }
  end
  
  def test_add_like_units
    unit1 = Unit.new("1 mm")
    unit2 = Unit.new("2 mm")
    assert_nothing_raised {  
      assert_equal 3.0, (unit1+unit2).scalar
      }
  end
  
  def test_add_similar_units
    unit1 = Unit.new("1 cm")
    unit2 = Unit.new("1 in")
    assert_nothing_raised {
      unit3 = unit1 + unit2
      assert_in_delta 3.54, unit3.scalar, 0.01
      }
  end

  def test_subtract_similar_units
    unit1 = Unit.new("1 cm")
    unit2 = Unit.new("1 in")
    assert_nothing_raised {
      unit3 = unit1 - unit2
      assert_in_delta(-1.54, unit3.scalar, 0.01)
      }
  end
  
  def test_add_unlike_units
    unit1 = Unit.new("1 mm")
    unit2 = Unit.new("2 ml")
    assert_raise(ArgumentError) {(unit1+unit2).scalar}
  end
  
  def test_add_coerce
    unit1 = "1 mm".unit
    assert_nothing_raised {
      unit2 = unit1 + "1 mm"
      assert_equal "2 mm".unit, unit2
    }
    assert_nothing_raised {
      unit2 = unit1 + [1,"mm"]
      assert_equal "2 mm".unit, unit2
    }
    assert_nothing_raised {
      unit2 = "1".unit + 1
      assert_equal "2".unit, unit2
    }
    assert_raises(ArgumentError) {
      "1".unit + nil
    }
  end

  def test_subtract_coerce
    unit1 = "1 mm".unit
    assert_nothing_raised {
      unit2 = unit1 - "1 mm"
      assert_equal "0 mm".unit, unit2
    }
  end
  def test_multiply_coerce
    unit1 = "1 mm".unit
    assert_nothing_raised {
      unit2 = unit1 * "1 mm"
      assert_equal "1 mm^2".unit, unit2
    }
  end
  def test_divide_coerce
    unit1 = "1 mm".unit
    assert_nothing_raised {
      unit2 = unit1 / "1 mm"
      assert_equal "1".unit, unit2
    }
  end
  
  def test_signature #"1 m s deg K kg A mol cd byte rad
    unit1 = Unit.new("1 m*s*degK*kg*A*mol*cd*byte*rad*dollar")
    assert_equal unit1.signature, (0..9).inject(0) {|product, n| product + 20**n}
  end
  
  def test_subtract_like_units
    unit1 = Unit.new("1 mm")
    unit2 = Unit.new("2 mm")
    assert_nothing_raised {
      assert_equal(-1, (unit1-unit2).scalar)
      }
  end
  
  def test_subtract_unlike_units
    unit1 = Unit.new("1 mm")
    unit2 = Unit.new("2 ml")
    assert_raise(ArgumentError) {(unit1-unit2).scalar}
  end
  
  def test_multiply
    unit1 = Unit.new("1 m/ms")
    unit2 = Unit.new("1 m/ms")
    assert_nothing_raised {
      unit3 = unit1 * unit2
      assert_equal Unit.new("1 m^2/ms^2"), unit3    
    }
    assert_equal unit1 * 0, '0 m/ms'.unit
  end
  
  def test_divide
    unit1 = Unit.new("200 M*g/mol")
    unit2 = Unit.new("200 g/mole")
    assert_nothing_raised {
      unit3 = unit1 / unit2
      assert_equal Unit.new("1 M"), unit3
      }
    assert_equal unit2 / 1, unit2
    unit3 = '0 s'.unit
    assert_raises(ZeroDivisionError) {
      unit1 / unit3
    }
    
    assert_raises(ZeroDivisionError) {
      unit1 / 0
    }
  end
  
  def test_inverse
    unit1 = Unit.new("1 m")
    unit2 = Unit.new("1 1/m")
    assert_equal unit2, unit1.inverse
    assert_raises((ZeroDivisionError)) { 0.unit.inverse }
  end
  
  def test_exponentiate_positive
    unit1 = Unit.new("1 mm")
    unit2 = Unit.new("1 mm^2")
    assert_nothing_raised {
      assert_equal unit2, unit1**2
      }
  end
  
  def test_exponentiate_float
    unit1 = Unit.new("1 mm")
    assert_raise(ArgumentError) {unit1**2.5}
  end
   
  def test_exponentiate_negative
    unit1 = Unit.new("1 m")
    unit2 = Unit.new("1 m^-2")
    assert_nothing_raised {
      assert_equal unit2, unit1**-2
      }
    assert_raises(ZeroDivisionError) {
      "0 mm".unit**-1
    }
  end

  def test_exponentiate_zero
    unit1 = Unit.new("10 mm")
    unit2 = Unit.new("1")
    assert_nothing_raised {
      assert_equal unit2, unit1**0
    }
    assert_equal 1, "0 mm".unit**0
  end
  
  def test_abs
    unit1 = Unit.new("-1 mm")
    assert_equal "1 mm".unit, unit1.abs
  end
  
  def test_ceil
    unit1 = Unit.new("1.1 mm")
    unit2 = Unit.new("2 mm")
    assert_equal unit2, unit1.ceil
    assert_equal(('1 mm'.unit / '1 mm'.unit).ceil, 1)  
    assert_equal("11 kg*m".unit, ("1003 kg*m".unit / 100).ceil)
  end
  
  def test_floor
    unit1 = Unit.new("1.1 mm")
    unit2 = Unit.new("1 mm")
    assert_equal unit2, unit1.floor
    assert_equal(('1 mm'.unit / '1 mm'.unit).floor, 1)
  end
  
  def test_to_int
    assert_raises(RuntimeError)  {Unit.new("1.1 mm").to_i}
    assert_nothing_raised {Unit.new(10.5).to_i}
  end
  
  def test_truncate
    unit1 = Unit.new("1.1 mm")
    unit2 = Unit.new("1 mm")
    assert_equal unit2, unit1.truncate
    assert_equal((unit1/unit2).truncate, 1)
  end
  
  def test_round
    unit1 = Unit.new("1.1 mm")
    unit2 = Unit.new("1 mm")
    assert_equal unit2, unit1.round
    assert_equal((unit1/unit2).round, 1)
  end
  
  def test_zero?
    unit1 = Unit.new("0")
    assert unit1.zero?
  end
  
  def test_nonzero?
    unit1 = Unit.new("0")
    unit2 = Unit.new("1 mm")
    assert_nil unit1.nonzero?
    assert_equal unit2, unit2.nonzero?
  end
  
  def test_equality
    unit1 = Unit.new("1 cm")
    unit2 = Unit.new("10 mm")
    assert unit1 == unit2
  end
  
  def test_temperature_conversions
    assert_raises(ArgumentError) { '-1 tempK'.unit}
    assert_raises(ArgumentError) { '-1 tempR'.unit}
    assert_raises(ArgumentError) { '-1000 tempC'.unit}
    assert_raises(ArgumentError) { '-1000 tempF'.unit}
    
    assert_in_delta '32 tempF'.unit.base_scalar, '0 tempC'.unit.base_scalar, 0.01
    assert_in_delta '0 tempC'.unit.base_scalar, '32 tempF'.unit.base_scalar, 0.01
    assert_in_delta '0 tempC'.unit.base_scalar, '273.15 tempK'.unit.base_scalar, 0.01
    assert_in_delta '0 tempC'.unit.base_scalar, '491.67 tempR'.unit.base_scalar, 0.01
    
    a = '10 degC'.unit
    assert_equal a >> 'tempC', '-263.15 tempC'.unit
    assert_equal a >> 'tempK', '10 tempK'.unit
    assert_equal a >> 'tempR', '18 tempR'.unit
    assert_equal a >> 'tempF', '-441.67 tempF'.unit
    
    unit1 = '37 tempC'.unit
    assert_equal unit1 >> 'tempF' >> 'tempK' >> 'tempR' >> 'tempC', unit1
    
    a = '100 tempF'.unit
    b = '10 degC'.unit
    c = '50 tempF'.unit
    d = '18 degF'.unit
    assert_equal('118 tempF'.unit,a+b)
    assert_equal b+a, '118 tempF'.unit
    assert_equal a-b, '82 tempF'.unit
    assert_in_delta((a-c).scalar, '50 degF'.unit.scalar, 0.01)
    assert_in_delta '20 degC'.unit, b+d, Unit("0.01 degC")
    assert_raises(ArgumentError) { a * b }
    assert_raises(ArgumentError) { a / b }
    assert_raises(ArgumentError) { a ** 2 }
    assert_raises(ArgumentError) { c - '400 degK'.unit}
    assert_equal a, a.to('tempF')
  end
  
  def test_feet
    unit1 = Unit.new("6'6\"")
    assert_in_delta 6.5, unit1.scalar, 0.01
    unit2 = "6'".unit
    assert_equal unit2, '6 feet'.unit
    unit3 = '6"'.unit
    assert_equal unit3, '6 inch'.unit

  end
  
  def test_pounds
    unit1 = Unit.new("8 pounds, 8 ounces")
    assert_in_delta 8.5, unit1.scalar, 0.01
    assert_equal '150#'.unit, '150 lbs'.unit
  end
  
  # these units are 'ambiguous' and could be mis-parsed
  def test_parse_tricky_units
    unit1 = Unit.new('1 mm')      #sometimes parsed as 'm*m'
    assert_equal ['<milli>','<meter>'], unit1.numerator
    unit2 = Unit.new('1 cd')      # could be a 'centi-day' instead of a candela
    assert_equal ['<candela>'], unit2.numerator
    unit3 = Unit.new('1 min')      # could be a 'milli-inch' instead of a minute
    assert_equal ['<minute>'], unit3.numerator
    unit4 = Unit.new('1 ft')      # could be a 'femto-ton' instead of a foot
    assert_equal ['<foot>'], unit4.numerator  
    unit5 = "1 atm".unit
    assert_equal ['<atm>'], unit5.numerator
    unit6 = "1 doz".unit
    assert_equal ['<dozen>'], unit6.numerator
  end
   
  def test_to_s
    unit1 = Unit.new("1")
    assert_equal "1", unit1.to_s
    unit2 = Unit.new("mm")
    assert_equal "1 mm", unit2.to_s
    assert_equal "0.04 in", unit2.to_s("%0.2f in")
    assert_equal "1/10 cm", unit2.to_s("cm")
    unit3 = Unit.new("1 mm")
    assert_equal "1 mm", unit3.to_s
    assert_equal "0.04 in", unit3.to_s("%0.2f in")
    unit4 = Unit.new("1 mm^2")
    assert_equal "1 mm^2", unit4.to_s
    unit5 = Unit.new("1 mm^2 s^-2")
    assert_equal "1 mm^2/s^2", unit5.to_s
    unit6= Unit.new("1 kg*m/s")
    assert_equal "1 kg*m/s", unit6.to_s
    unit7= Unit.new("1 1/m")
    assert_equal "1 1/m", unit7.to_s
    assert_equal("1.5 mm", Unit.new("1.5 mm").to_s)
    assert_equal("1.5 mm", "#{Unit.new('1.5 mm')}")
  end
  
  def test_to_feet_inches
    unit1 = Unit.new("6'5\"")
    assert_equal "6'5\"", unit1.to_s(:ft)
    assert_raises(ArgumentError) {
      unit1 = Unit.new("1 kg")
      unit1.to_s(:ft)
    }
  end
  
  def test_to_lbs_oz
    unit1 = Unit.new("8 lbs 8 oz")
    assert_equal "8 lbs, 8 oz", unit1.to_s(:lbs)
    assert_raises(ArgumentError) {
      unit1 = Unit.new("1 m")
      unit1.to_s(:lbs)
    }
  end
  
  def test_add_units
    a = Unit.new("1 inchworm")
    assert_equal "1 inworm", a.to_s
  end
  
  def test_ideal_gas_law
    p = Unit "100 kPa"
    v = Unit "1 m^3"
    n = Unit "1 mole"
    r = Unit "8.31451 J/mol*degK"
    t = ((p*v)/(n*r)).to('tempK')
    assert_in_delta 12027.16,t.base_scalar, 0.1
  end
  
  
  def test_eliminate_terms
    a = ['<meter>','<meter>','<kelvin>','<second>']
    b = ['<meter>','<meter>','<second>']
    h = Unit.eliminate_terms(1,a,b)
    assert_equal ['<kelvin>'], h[:numerator]
  end
  
  def test_to_base_consistency
    a = "1 W*m/J*s".unit
    assert_equal a.signature, a.to_base.signature
  end
  
  def test_unit_roots
    unit1 = Unit "2 m*J*kg"
    unit2 = Unit "4 m^2*J^2*kg^2"
    unit3 = Unit "8 m^3*J^3*kg^3"
    assert_equal unit2**(1/2), unit1
    assert_equal unit3**(1/3), unit1
  end
  
  def test_inspect
    unit1 = Unit "1 mm"
    assert_equal "1 mm", unit1.inspect
    assert_not_equal "1.0 mm", unit1.inspect(:dump)
  end
  
  def test_to_f
    assert_equal 1, 1.unit.to_f
    assert_raises(RuntimeError) {
      assert_equal 1, "1 mm".unit.to_f
    }
  end
  
  def test_exponentiate_float2
    assert_equal "2 m".unit, "4 m^2".unit**(0.5) 
    assert_raises(ArgumentError) { "1 mm".unit**(2/3)}
    assert_raises(ArgumentError) { "1 mm".unit**("A")}
    
  end
  
  def test_range
    a = Unit "1 mm"
    b = Unit "3 mm"
    c = (a..b).to_a
    assert_equal ["1 mm".unit, "2 mm".unit, "3 mm".unit], c
  end
  
  def test_scientific
    a = Unit "1e6 cells"
    assert_equal 1e6, a.scalar
    assert_equal "cells", a.units
  end
  
	if defined?(Uncertain)
		def test_uncertain
			a = '1 +/- 1 mm'.unit
			assert_equal a.to_s, '1 +/- 1 mm' 
		end  
	end
  
  def test_format
    assert_equal "%0.2f" % "1 mm".unit, "1.00 mm" 
  end
  
  def test_bad_units
    assert_raises(ArgumentError) { '1 doohickey / thingamabob'.unit}
    assert_raises(ArgumentError) { '1 minimeter'.unit}
  end
  
  def test_currency
    assert_nothing_raised {"$1".unit}
  end
  
  def test_kind
    a = "1 mm".unit
    assert_equal a.kind, :length
  end
  
  def test_percent
      assert_nothing_raised {
      	"1 percent".unit
        "1%".unit
        "0.01%".unit
      }
      a = '100 ml'.unit
      b = '50%'.unit
      c = a*b >> 'ml'
      assert c =~ a
      assert_in_delta '50 ml'.unit.scalar, c.scalar, 0.0001
  end
  
  def test_parse
    assert_nothing_raised { "1 1/m".unit }
    assert_raises(ArgumentError) { "3 s/s/ft".unit }
    assert_raises(ArgumentError) { "3 s**2|,s**2".unit }
    assert_raises(ArgumentError) { "3 s**2 4s s**2".unit }
    assert_raises(ArgumentError) { "3 s 5^6".unit }
    assert_raises(ArgumentError) { "".unit }
    assert_raises(ArgumentError) { " ".unit }
    assert_raises(ArgumentError) { "\t".unit }
    assert_raises(ArgumentError) { "\t\t".unit }
    assert_raises(ArgumentError) { "\n".unit }
  end
  
  def test_inline_conversions
    assert_equal "60 s".unit, Unit.parse("1 min to seconds")
    assert_equal "60 s".unit, Unit.parse("1 min as seconds")
    assert_equal "60 s".unit, Unit.parse("1 min in seconds")
  end
  
  def test_time_conversions
    today = 'now'.to_time
    assert_equal today,@april_fools
    last_century = today - '150 years'.unit
    assert_equal last_century.to_date, '1856-04-01'.to_date
  end
  
  def test_coercion
    assert_nothing_raised { 1.0 * '1 mm'.unit}
    assert_nothing_raised { '1 mm'.unit * 1.0}
  end
  
  def test_zero
    assert_nothing_raised { Unit.new(0) }
  end
  
  def test_divide_results_in_unitless
    a = '10 mg/ml'.unit
    b = '10 mg/ml'.unit
    assert_equal a/b, 1
  end

  def test_wt_percent
    a = '1 wt%'.unit
    b = '1 g/dl'.unit
    assert_equal a,b
  end
  
  def test_parse_durations
    assert_equal "1:00".unit, '1 hour'.unit
    assert_equal "1:30".unit, "1.5 hour".unit
    assert_equal "1:30:30".unit, "1.5 hour".unit + '30 sec'.unit
    assert_equal "1:30:30,200".unit, "1.5 hour".unit + '30 sec'.unit + '200 usec'.unit
  end
  
  def test_coercion_2
    a = Dummy.new
    b = '1 mm'.unit
    assert_equal '2 mm'.unit, b + a
  end
  
  def test_create_with_other_unit
    a = '1 g'.unit
    b = 0.unit(a)
    assert_equal b, '0 g'.unit
  end
  
  def test_sqrt
    a = '-9 mm^2'.unit
    b = a**(0.5)
    assert_in_delta Math.sqrt(a).to_unit.scalar.real, b.scalar.real, 0.00001
		# ruby 1.8.x uses .image while 1.9.x uses .imaginary
		if Complex.instance_methods.include?(:imaginary)
    	assert_in_delta Math.sqrt(a).to_unit.scalar.imaginary, b.scalar.imaginary, 0.00001
		else
			assert_in_delta Math.sqrt(a).to_unit.scalar.image, b.scalar.image, 0.00001
		end
  end

	def test_div
		assert_equal 11,"23 m".unit.div('2 m'.unit)
	end
	
	def test_divmod
		assert_equal [277,1], 555.unit('mm').divmod(2.unit('mm'))
		assert_equal [277, 0.0010000000000000373], '0.555 m'.unit.divmod('2 mm'.unit)
		assert_raises(ArgumentError) { '1 m'.unit.divmod('1 kg'.unit) }
	end

	if Math.respond_to?(:cbrt)
		def test_cbrt
			assert_in_delta '2 mm'.to_unit, Math.cbrt('8 mm^3'.to_unit), 0.0001
		end
	end
  
  def test_hypot
    assert_equal Math.hypot('3 mm'.unit,'4 mm'.unit), '5 mm'.unit
    assert_raises(ArgumentError) { Math.hypot('3 mm'.unit, '4 kg'.unit)}
  end
  
  def test_complex
    assert_equal '1+1i mm'.unit.scalar, Complex(1,1)
    assert_equal '1+1i'.unit.scalar, Complex(1,1)
    assert_raises(RuntimeError) { '1+1i mm'.unit.to_c}
  end

  def test_atan2
    assert_equal Math.atan2('1 mm'.unit,'1 mm'.unit), Math.atan2(1,1)
    assert_raises(ArgumentError) {Math.atan2('1 mm'.unit, '1 lb'.unit)}
    assert_raises(ArgumentError) {Math.atan2('1 mm'.unit, 1)}
  end

  def test_rational_units
    assert_equal '1/4 cup'.unit, '0.25 cup'.unit
    assert_equal '1/4 in/s'.unit, '0.25 in/s'.unit
    assert_equal '1/4'.unit, 0.25
  end
  
  def test_to_date
    a = Time.now
    assert_equal a.send(:to_date), Date.today
  end
  
  def test_natural_language
    assert_equal Unit.parse("10 mm in cm"), '10 mm'.unit.to('cm')
  end
  
  def test_round_pounds
    assert_equal '1 lbs'.unit, '1.1 lbs'.unit.round
  end

  def test_explicit_init
    assert_equal '1 lbf'.unit, '1 <pound-force>'.unit
    assert_equal '1 lbs'.unit, '1 <pound>'.unit
    assert_equal('1 kg*m'.unit, '1 <kilogram>*<meter>'.unit)
  end
  
  def test_format_nil_string
    assert_nothing_raised {"" % nil}
    assert_nothing_raised {"" % false}
  end
  
  def test_to_s_cache
    Unit.clear_cache
    a = Unit.new('1 mm')
    a.to_s                # cache the conversion to itself
    b = Unit.new('2 mm')
    assert_equal('2 mm', b.to_s)
    assert_equal('1/1000 m', a.to_s('m'))
    assert_equal('1/1000 m', a.output['m'])
  end
    
  def test_version
    assert_equal('1.2.0', Unit::VERSION)
  end
  
  def test_negation
    a = 1.to_unit
    assert_equal(a.class, (1-a).class)
  end
  
  def test_degree
    assert "100 tempF".unit.degree?
    assert "100 degC".unit.degree?
    assert !"1 mm".unit.degree?
  end

  def test_temperature
    assert "100 tempF".unit.temperature?
    assert !"100 degC".unit.temperature?
    assert !"1 mm".unit.temperature?    
  end
  
  def test_parse_into_numbers_and_units
    assert_equal([1,"m"], Unit.parse_into_numbers_and_units("1 m"))
    assert_equal([1.0,"m"], Unit.parse_into_numbers_and_units("1.0 m"))
    assert_equal([0.1,"m"], Unit.parse_into_numbers_and_units("0.1 m"))
    assert_equal([0.1,"m"], Unit.parse_into_numbers_and_units(".1 m"))
    assert_equal([-1.23E-3,"m"], Unit.parse_into_numbers_and_units("-1.23E-3 m"))
    assert_equal([1/4,"m"], Unit.parse_into_numbers_and_units("1/4 m"))
    assert_equal([-1/4,"m"], Unit.parse_into_numbers_and_units("-1/4 m"))
    assert_equal([1,"m"], Unit.parse_into_numbers_and_units("1   m"))
    assert_equal([1,"m"], Unit.parse_into_numbers_and_units("m"))
    assert_equal([10,""], Unit.parse_into_numbers_and_units("10"))
    assert_equal([10.0,""], Unit.parse_into_numbers_and_units("10.0"))
    assert_equal([(1/4),""], Unit.parse_into_numbers_and_units("1/4"))
    assert_equal([Complex(1,1),""], Unit.parse_into_numbers_and_units("1+1i"))
  end

end

