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
    assert_in_delta '20 degC'.unit.scalar, (b+d).scalar, 0.01
    assert_raises(ArgumentError) { a * b }
    assert_raises(ArgumentError) { a / b }
    assert_raises(ArgumentError) { a ** 2 }
    assert_raises(ArgumentError) { c - '400 degK'.unit}
    assert_equal a, a.convert_to('tempF')
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
      
  def test_ideal_gas_law
    p = Unit "100 kPa"
    v = Unit "1 m^3"
    n = Unit "1 mole"
    r = Unit "8.31451 J/mol*degK"
    t = ((p*v)/(n*r)).convert_to('tempK')
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
  
  def test_time_conversions
    today = Time.now
    assert_equal today,@april_fools
    last_century = today - '150 years'.unit
    assert_equal last_century.to_date, DateTime.parse('1856-04-01')
  end
    
  def test_parse_durations
    assert_equal "1:00".unit, '1 hour'.unit
    assert_equal "1:30".unit, "1.5 hour".unit
    assert_equal "1:30:30".unit, "1.5 hour".unit + '30 sec'.unit
    assert_equal "1:30:30,200".unit, "1.5 hour".unit + '30 sec'.unit + '200 usec'.unit
  end
    
  def test_to_date
    a = Time.now
    assert_equal a.send(:to_date), Date.today
  end
  
  def test_explicit_init
    assert_equal '1 lbf'.unit, '1 <pound-force>'.unit
    assert_equal '1 lbs'.unit, '1 <pound>'.unit
    assert_equal('1 kg*m'.unit, '1 <kilogram>*<meter>'.unit)
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

