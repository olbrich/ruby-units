require 'test_helper'
require 'rubygems'
require 'test/unit'
require 'ruby-units'

class TestCache < Test::Unit::TestCase
  def setup
    Unit::Cache.clear
  end
  
  def test_clear
    Unit::Cache.set("m", "m".unit)
    Unit::Cache.clear
    assert_nil(Unit::Cache.get('m'))
  end
  
  def test_set_cache
    assert_nothing_raised { Unit::Cache.set("m", "m".unit) }
    assert Unit::Cache.get.keys.include?('m')
  end
  
  def test_get_cache
    Unit::Cache.set("m", "m".unit)
    assert_equal("m".unit, Unit::Cache.get['m'])
  end
  
end
