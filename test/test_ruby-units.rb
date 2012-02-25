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
  
  def test_time_conversions
    today = Time.now
    assert_equal today,@april_fools
    last_century = today - '150 years'.unit
    assert_equal last_century.to_date, DateTime.parse('1856-04-01')
  end


end

