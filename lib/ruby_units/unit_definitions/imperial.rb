require_relative 'si'

# US customary units are defined in terms of metric units

RubyUnits::UnitSystem.new('US Customary', :us) do
  define :point do
    definition { RubyUnits::Unit.new((1 / 72), 'in') }
    aliases %w(pt pts point points)
  end

  define :pica do
    definition { RubyUnits::Unit.new(12, 'pt') }
    aliases %w(pc pcs pica picas)
  end

  define :inch do
    definition { RubyUnits::Unit.new((1 / 12), 'ft') }
    aliases %w(in inch inches ")
  end

  define :foot do
    definition { RubyUnits::Unit.new(0.3048, 'm') }
    aliases %w(ft foot feet ')
  end

  define :yard do
    definition { RubyUnits::Unit.new(3, 'ft') }
    aliases %w(yd yard yards)
  end

  define :mile do
    definition { RubyUnits::Unit.new(5280, 'ft') }
    aliases %w(mi mile miles)
  end

  define :link do
    definition { RubyUnits::Unit.new(33 / 50, 'ft') }
    aliases %w(li link links)
  end

  define :"survey-foot" do
    definition { RubyUnits::Unit.new(1200 / 3937, 'm') }
    aliases %w(sft survey-foot survey-feet)
  end

  define :rod do
    definition { RubyUnits::Unit.new(25, 'li') }
    aliases %w(rd rod rods)
  end

  define :chain do
    definition { RubyUnits::Unit.new(4, 'rd') }
    aliases %w(ch chain chains)
  end

  define :furlong do
    definition { RubyUnits::Unit.new(10, 'ch') }
    aliases %w(fur furlong furlongs)
  end

  define :"survey-mile" do
    definition { RubyUnits::Unit.new(8, 'fur') }
    aliases %w(smi survey-mile survey-miles)
  end

  define :league do
    definition { RubyUnits::Unit.new(3, 'mi') }
    aliases %w(lea league leagues)
  end

  define :fathom do
    definition { RubyUnits::Unit.new(2, 'yd') }
    aliases %w(ftm fathom fathoms)
  end

  define :cable do
    definition { RubyUnits::Unit.new(120, 'fth') }
    aliases %w(cb cable cables)
  end

  define :"nautical-mile" do
    definition { RubyUnits::Unit.new(1.852, 'km') }
    aliases %w(nmi nautical-mile nautical-miles)
  end

  define :sqft do
    definition { RubyUnits::Unit.new(1, 'ft')**2 }
    aliases %w(sqft)
  end

  define :sqch do
    definition { RubyUnits::Unit.new(16, 'rd')**2 }
    aliases %w(sqch)
  end

  define :acre do
    definition { RubyUnits::Unit.new(10, 'ch')**2 }
    aliases %w(acre acres)
  end

  define :section do
    definition { RubyUnits::Unit.new(640, 'acre') }
    aliases %w(section sections)
  end

  define :"survey-township" do
    definition { RubyUnits::Unit.new(36, 'sections') }
    aliases %w(twp survey-township survey-townships)
  end

  define :"cubic-inch" do
    definition { RubyUnits::Unit.new(1, 'in')**3 }
    aliases %w(cuin cubic-inch cubic-inches)
  end

  define :"cubic-feet" do
    definition { RubyUnits::Unit.new(1, 'ft')**3 }
    aliases %w(cuft cubic-foot cubic-feet)
  end

  define :"cubic-yard" do
    definition { RubyUnits::Unit.new(1, 'yd')**3 }
    aliases %w(cuyd cubic-yard cubic-yards)
  end

  define :"acre-foot" do
    definition { RubyUnits::Unit.new(1, 'acre*ft') }
    aliases %w(acre-ft acre-foot acre-feet)
  end

  define :hogshead do
    definition { RubyUnits::Unit.new(238.480942392, 'l') }
    aliases %w(hogshead hogsheads)
  end

  define :barrel do
    definition { RubyUnits::Unit.new(1/2, 'hogshead') }
    aliases %w(bbl barrel barrels)
  end

  define :gallon do
    definition { RubyUnits::Unit.new(4, 'qt') }
    aliases %w(gal gallon gallons)
  end

  define :quart do
    definition { RubyUnits::Unit.new(2, 'pt') }
    aliases %w(qt quart quarts)
  end

  define :pint do
    definition { RubyUnits::Unit.new(2, 'cp') }
    aliases %w(pt pint pints)
  end

  define :cup do
    definition { RubyUnits::Unit.new(8, 'floz') }
    aliases %w(cp cup cups)
  end

  define :gill do
    definition { RubyUnits::Unit.new(4, 'floz') }
    aliases %w(gi gill gills)
  end

  define :shot do
    definition { RubyUnits::Unit.new(3, 'tbsp') }
    aliases %w(shot shots jig)
  end

  define :floz do
    definition { RubyUnits::Unit.new(2, 'tbsp') }
    aliases %w(floz fluid-ounce fluid-ounces)
  end

  define :tablespoon do
    definition { RubyUnits::Unit.new(3, 'tsp') }
    aliases %w(tbsp Tbsp tablespoon tablespoons)
  end

  define :teaspoon do
    definition { RubyUnits::Unit.new(4.92892159375, 'mL') }
    aliases %w(tsp teaspoon teaspoons)
  end

  define :"fluid-dram" do
    definition { RubyUnits::Unit.new(3.6966911953125, 'mL') }
    aliases %w(fldr fluid-dram fluid-drams)
  end

  define :grain do
    definition { RubyUnits::Unit.new(1/7000, 'lb') }
    aliases %w(gr grain grains)
  end

  define :dram do
    definition { RubyUnits::Unit.new(27+11/32, 'gr') }
    aliases %w(dr dram drams)
  end

  define :ounce do
    definition { RubyUnits::Unit.new(16, 'dr') }
    aliases %w(oz ounce ounces)
  end

  define :pound do
    definition { RubyUnits::Unit.new(16, 'oz') }
    aliases %w(lb lbs pound pounds)
  end

  define :ton do
    definition { RubyUnits::Unit.new(2000, 'lbs') }
    aliases %w(tn ton tons short-ton short-tons)
  end

  define :"long-ton" do
    definition { RubyUnits::Unit.new(2240, 'lbs') }
    aliases %w(long-ton long-tons)
  end

  define :pennyweight do
    definition { RubyUnits::Unit.new(24, 'gr') }
    aliases %w(dwt pennyweight)
  end

  define :"troy-ounce" do
    definition { RubyUnits::Unit.new(20, 'dwt') }
    aliases %w(ozt troy-ounce troy-ounces)
  end

  define :"troy-pound" do
    definition { RubyUnits::Unit.new(12, 'ozt') }
    aliases %w(lbt troy-pound troy-pounds)
  end

  define :"board-foot" do
    definition { RubyUnits::Unit.new(1, 'ft') * RubyUnits::Unit.new(1, 'in')**2 }
    aliases %w(bdft board-foot board-feet)
  end

  define :btu do
    definition { RubyUnits::Unit.new(1055.056, 'J') }
    aliases %w(btu BTU)
  end

  define :calorie do
    definition { RubyUnits::Unit.new(4.184, 'J') }
    aliases %w(cal calorie)
  end

  define :Calorie do
    definition { RubyUnits::Unit.new(1000, 'cal') }
    aliases %w(Cal)
  end

  define :horsepower do
    definition { RubyUnits::Unit.new('33000 ft*lbf/min') }
    aliases %w(hp horsepower)
  end
end
