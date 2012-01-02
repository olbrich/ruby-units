# length units

Unit.define!('inch') do |inch|
  inch.definition = Unit('254/10000 meter')
  inch.aliases    = %w{in inch inches "}
end

Unit.define!('foot') do |foot|
  foot.definition = Unit('12 inches')
  foot.aliases    = %w{ft foot feet '}
end

Unit.define('survey-foot') do |sft|
  sft.definition = Unit('1200/3937 meter')
  sft.aliases    = %w{sft sfoot sfeet}
end

Unit.define('yard') do |yard|
  yard.definition = Unit('3 ft')
  yard.aliases    = %w{yd yard yards}
end

Unit.define!('mile') do |mile|
  mile.definition = Unit('5280 ft')
  mile.aliases    = %w{mi mile miles}
end

Unit.define!('naut-mile') do |naut|
  naut.definition = Unit('1852 m')
  naut.aliases    = %w{nmi M NM}
end

# on land
Unit.define('league') do |league|
  league.definition = Unit('3 miles')
  league.aliases    = %w{league leagues}
end

# at sea
Unit.define('naut-league') do |naut_league|
  naut_league.definition = Unit('3 nmi')
  naut_league.aliases    = %w{nleague nleagues}
end

Unit.define('furlong') do |furlong|
  furlong.definition = Unit('1/8 mile')
  furlong.aliases    = %w{fur furlong furlongs}
end

Unit.define('rod') do |rod|
  rod.definition  = Unit('33/2 feet')
  rod.aliases     = %w{rd rod rods}
end

Unit.define('fathom') do |fathom|
  fathom.definition = Unit('6 ft')
  fathom.aliases    = %w{fathom fathoms}
end

Unit.define('mil') do |mil|
  mil.definition = Unit('1/1000 inch')
  mil.aliases    = %w{mil mils}
end

Unit.define('angstrom') do |ang|
  ang.definition = Unit('1/10 nm')
  ang.aliases    = %w{ang angstrom angstroms}
end

# typesetting

Unit.define!('point') do |point|
  point.definition = Unit('1/72 ft')
  point.aliases    = %w{pt point points}
end

Unit.define('pica') do |pica|
  pica.definition = Unit('12 pt')
  pica.aliases    = %w{P pica picas}
end

Unit.define!('dot') do |dot|
  dot.definition  = Unit('1 each')
  dot.aliases     = %w{dot dots}
  dot.kind        = :counting
end

Unit.define!('pixel') do |pixel|
  pixel.definition  = Unit('1 each')
  pixel.aliases     = %w{px pixel pixels}
  pixel.kind        = :counting
end

Unit.define('ppi') do |ppi|
  ppi.definition  = Unit('1 pixel/inch')
end

Unit.define('dpi') do |dpi|
  dpi.definition  = Unit('1 dot/inch')
end

# Mass

avagadro_constant = Unit('6.02214129e23 1/mol')

Unit.define!('AMU') do |amu|
  amu.definition = Unit('12 kg/mol') / (12 * avagadro_constant)
  amu.aliases    = %w{u AMU amu}
end

Unit.define('dalton') do |dalton|
  dalton.definition = Unit('1 amu')
  dalton.aliases    = %w{Da dalton daltons}
end

standard_gravitation = Unit('9.80665 m/s^2')

Unit.define('metric-ton') do |mton|
  mton.definition = Unit('1000 kg')
  mton.aliases    = %w{tonne}
end

# defined as a rational number to preserve accuracy and minimize round-off errors during
# calculations
Unit.define!('pound') do |pound|
  pound.definition = Unit(Rational(8171193714040401,18014398509481984), 'kg')
  pound.aliases    = %w{lbs lb lbm pound-mass pound pounds #}
end

Unit.define('ounce') do |ounce|
  ounce.definition = Unit('1/16 lbs')
  ounce.aliases    = %w{oz ounce ounces}
end

Unit.define('gram') do |gram|
  gram.definition = Unit('1/1000 kg')
  gram.aliases    = %w{g gram grams gramme grammes}
end

Unit.define('short-ton') do |ton|
  ton.definition = Unit('2000 lbs')
  ton.aliases    = %w{ton tn}
end

Unit.define('carat') do |carat|
  carat.definition = Unit('1/5000 kg')
  carat.aliases    = %w{ct carat carats}
end

# time

Unit.define!('minute') do |min|
  min.definition = Unit('60 seconds')
  min.aliases    = %w{min minute minutes}
end

Unit.define!('hour') do |hour|
  hour.definition = Unit('60 minutes')
  hour.aliases    = %w{h hr hrs hour hours}
end

Unit.define!('day') do |day|
  day.definition  = Unit('24 hours')
  day.aliases     = %w{d day days}
end

Unit.define!('week') do |week|
  week.definition   = Unit('7 days')
  week.aliases      = %w{wk week weeks}
end

Unit.define('fortnight') do |fortnight|
  fortnight.definition  = Unit('2 weeks')
  fortnight.aliases     = %w{fortnight fortnights}
end

Unit.define!('year') do |year|
  year.definition = Unit('31556926 seconds') # works out to 365.24219907407405 days
  year.aliases    = %w{y yr year years annum}
end

Unit.define('decade') do |decade|
  decade.definition = Unit('10 years')
  decade.aliases    = %w{decade decades}
end

Unit.define('century') do |century|
  century.definition  = Unit('100 years')
  century.aliases     = %w{century centuries}
end

# area

Unit.define('hectare') do |hectare|
  hectare.definition = Unit('10000 m^2')
end

Unit.define('acre') do |acre|
  acre.definition = Unit('1 mi')**2 / 640
  acre.aliases    = %w{acre acres}
end

Unit.define('sqft') do |sqft|
  sqft.definition = Unit('1 ft^2')
end

Unit.define('sqin') do |sqin|
  sqin.definition = Unit('1 in^2')
end

# volume

Unit.define('liter') do |liter|
  liter.definition = Unit('1/1000 m^3')
  liter.aliases    = %w{l L liter liters litre litres}
end

Unit.define!('gallon') do |gallon|
  gallon.definition = Unit('231 in^3')
  gallon.aliases    = %w{gal gallon gallons}
end

Unit.define('quart') do |quart|
  quart.definition  = Unit('1/4 gal')
  quart.aliases     = %w{qt quart quarts}
end

Unit.define('pint') do |pint|
  pint.definition = Unit('1/8 gal')
  pint.aliases    = %w{pt pint pints}
end

Unit.define('cup') do |cup|
  cup.definition = Unit('1/16 gal')
  cup.aliases    = %w{cu cup cups}
end

Unit.define!('fluid-ounce') do |floz|
  floz.definition = Unit('1/128 gal')
  floz.aliases    = %w{floz fluid-ounce}
end

Unit.define!('tablespoon') do |tbsp|
  tbsp.definition = Unit('1/2 floz')
  tbsp.aliases    = %w{tbs tbsp tablespoon tablespoons}
end

Unit.define('teaspoon') do |tsp|
  tsp.definition = Unit('1/3 tablespoon')
  tsp.aliases    = %w{tsp teaspoon teaspoons}
end

# volumetric flow

Unit.define('cfm') do |cfm|
  cfm.definition = Unit('1 ft^3/minute')
  cfm.aliases    = %w{cfm CFM CFPM}
end

# speed

Unit.define('kph') do |kph|
  kph.definition  = Unit('1 kilometer/hour')
end

Unit.define('mph') do |mph|
  mph.definition  = Unit('1 mile/hour')
end

Unit.define('fps') do |fps|
  fps.definition  = Unit('1 foot/second')
end

Unit.define('knot') do |knot|
  knot.definition   = Unit('1 nmi/hour')
  knot.aliases      = %w{kt kn kts knot knots}
end

Unit.define!('gee') do |gee|
  # approximated as a rational number to minimize round-off errors
  gee.definition    = Unit(Rational(5520596865723767,562949953421312), 'm/s^2') # equivalent to 9.80655 m/s^2
  gee.aliases       = %w{gee standard-gravitation}
end

# temperature differences

Unit.define!('newton') do |newton|
  newton.definition = Unit('1 kg*m/s^2')
  newton.aliases    = %w{N newton newtons}
end

Unit.define('dyne') do |dyne|
  dyne.definition = Unit('1/100000 N')
  dyne.aliases    = %w{dyn dyne}
end

Unit.define!('pound-force') do |lbf|
  lbf.definition  = Unit('1 lb') * Unit('1 gee')
  lbf.aliases     = %w{lbf pound-force}
end

Unit.define('poundal') do |poundal|
  poundal.definition  = Unit('1 lb') * Unit('1 ft/s^2')
  poundal.aliases     = %w{pdl poundal poundals}
end

temp_convert_factor = Rational(2501999792983609,4503599627370496) # approximates 1/1.8

Unit.define('celsius') do |celsius|
  celsius.definition  = Unit('1 degK')
  celsius.aliases     = %w{degC celsius centigrade}
end

Unit.define!('fahrenheit') do |fahrenheit|
  fahrenheit.definition = Unit(temp_convert_factor, 'degK')  
  fahrenheit.aliases    = %w{degF fahrenheit}
end

Unit.define('rankine') do |rankine|
  rankine.definition  = Unit('1 degF')
  rankine.aliases     = %w{degR rankine}
end

Unit.define('tempC') do |tempC|
  tempC.definition  = Unit('1 tempK')
end

Unit.define!('tempF') do |tempF|
  tempF.definition  = Unit(temp_convert_factor, 'tempK')
end

Unit.define('tempR') do |tempR|
  tempR.definition  = Unit('1 tempF')
end

# astronomy

speed_of_light = Unit('299792458 m/s')

Unit.define('light-second') do |ls|
  ls.definition = Unit('1 s') * speed_of_light
  ls.aliases    = %w{ls lsec light-second}
end

Unit.define('light-minute') do |lmin|
  lmin.definition = Unit('1 min') * speed_of_light
  lmin.aliases    = %w{lmin light-minute}
end

Unit.define!('light-year') do |ly|
  ly.definition = Unit('1 y') * speed_of_light
  ly.aliases    = %w{ly light-year}
end

Unit.define('parsec') do |parsec|
  parsec.definition = Unit('3.26163626 ly')
  parsec.aliases    = %w{pc parsec parsecs}
end

# once was '149597900000 m' but there appears to be a more accurate estimate according to wikipedia
# see http://en.wikipedia.org/wiki/Astronomical_unit
Unit.define('AU') do |au|
  au.definition = Unit('149597870700 m')
  au.aliases    = %w{AU astronomical-unit}
end

Unit.define('redshift') do |red|
  red.definition = Unit('1.302773e26 m')
  red.aliases    = %w{z red-shift}
end

# mass

Unit.define('slug') do |slug|
  slug.definition = Unit('1 lbf*s^2/ft')
  slug.aliases    = %w{slug slugs} 
end

# pressure

Unit.define!('pascal') do |pascal|
  pascal.definition = Unit('1 kg/m*s^2')
  pascal.aliases    = %w{Pa pascal pascals}
end

Unit.define('bar') do |bar|
  bar.definition  = Unit('100 kPa')
  bar.aliases     = %w{bar bars}
end

Unit.define!('atm') do |atm|
  atm.definition  = Unit('101325 Pa')
  atm.aliases     = %w{atm ATM atmosphere atmospheres}
end

Unit.define('mmHg') do |mmhg|
  density_of_mercury  = Unit('7653360911758079/562949953421312 g/cm^3') # 13.5951 g/cm^3 at 0 tempC
  mmhg.definition     = Unit('1 mm') * Unit('1 gee') * density_of_mercury
end

Unit.define('inHg') do |inhg|
  density_of_mercury = Unit('7653360911758079/562949953421312 g/cm^3') # 13.5951 g/cm^3 at 0 tempC
  inhg.definition    = Unit('1 in') * Unit('1 gee') * density_of_mercury
end

Unit.define('torr') do |torr|
  torr.definition = Unit('1/760 atm')
  torr.aliases    = %w{Torr torr}
end

Unit.define('psi') do |psi|
  psi.definition  = Unit('1 lbf/in^2')
end

Unit.define('cmh2o') do |cmh2o|
  density_of_water  = Unit('1 g/cm^3') # at 4 tempC
  cmh2o.definition  = Unit('1 cm') * Unit('1 gee') * density_of_water
  cmh2o.aliases     = %w{cmH2O cmh2o cmAq}
end

Unit.define('inh2o') do |inh2o|
  density_of_water  = Unit('1 g/cm^3') # at 4 tempC
  inh2o.definition  = Unit('1 in') * Unit('1 gee') * density_of_water
  inh2o.aliases     = %w{inH2O inh2o inAq}  
end

#viscosity

Unit.define('poise') do |poise|
  poise.definition  = Unit('dPa*s')
  poise.aliases     = %w{P poise}
end

Unit.define('stokes') do |stokes|
  stokes.definition = Unit('1 cm^2/s')
  stokes.aliases    = %w{St stokes}
end

# #energy

Unit.define!('joule') do |joule|
  joule.definition  = Unit('1 N*m')
  joule.aliases     = %w{J joule joules}
end

Unit.define('erg') do |erg|
  erg.definition  = Unit('1 g*cm^2/s^2')
  erg.aliases     = %w{erg ergs}
end

#power

Unit.define!('watt') do |watt|
  watt.definition = Unit('1 N*m/s')
  watt.aliases    = %w{W Watt watt watts}
end

Unit.define('horsepower') do |hp|
  hp.definition = Unit('33000 ft*lbf/min')
  hp.aliases    = %w{hp horsepower}
end

# energy
Unit.define!('btu') do |btu|
  btu.definition  = Unit('2320092679909671/2199023255552 J') # 1055.056 J  --- ISO standard
  btu.aliases     = %w{Btu btu Btus btus}
end

Unit.define('therm') do |therm|
  therm.definition  = Unit('100 kBtu')
  therm.aliases     = %w{thm therm therms Therm}
end

# "small" calorie
Unit.define!('calorie') do |calorie|
  calorie.definition  = Unit('4.184 J')
  calorie.aliases     = %w{cal calorie calories}
end

# "big" calorie
Unit.define('Calorie') do |calorie|
  calorie.definition  = Unit('1 kcal')
  calorie.aliases     = %w{Cal Calorie Calories}
end

Unit.define('molar') do |molar|
  molar.definition  = Unit('1 mole/l')
  molar.aliases     = %w{M molar}
end

# potential
Unit.define!('volt') do |volt|
  volt.definition = Unit('1 W/A')
  volt.aliases    = %w{V volt volts}
end

# capacitance
Unit.define('farad') do |farad|
  farad.definition  = Unit('1 A*s/V')
  farad.aliases     = %w{F farad farads}
end

# charge
Unit.define('coulomb') do |coulomb|
  coulomb.definition  = Unit('1 A*s')
  coulomb.aliases     = %w{C coulomb coulombs}
end

# conductance
Unit.define('siemens') do |siemens|
  siemens.definition  = Unit('1 A/V')
  siemens.aliases     = %w{S siemens}
end

# inductance
Unit.define('henry') do |henry|
  henry.definition  = Unit('1 J/A^2')
  henry.aliases     = %w{H henry henries}
end

# resistance
Unit.define('ohm') do |ohm|
  ohm.definition  = Unit('1 V/A')
  ohm.aliases     = %w{Ohm ohm ohms}
end

# magnetism 

Unit.define('weber') do |weber|
  weber.definition  = Unit('1 V*s')
  weber.aliases     = %w{Wb weber webers}
end

Unit.define!('tesla') do |tesla|
  tesla.definition  = Unit('1 V*s/m^2')
  tesla.aliases     = %w{T tesla teslas}
end

Unit.define!('gauss') do |gauss|
  gauss.definition  = Unit('100 microT')
  gauss.aliases     = %w{G gauss}
end

Unit.define('maxwell') do |maxwell|
  maxwell.definition  = Unit('1 gauss*cm^2')
  maxwell.aliases     = %w{Mx maxwell maxwells}
end

Unit.define('oersted') do |oersted|
  oersted.definition  = Unit(250.0/Math::PI, 'A/m')
  oersted.aliases     = %w{Oe oersted oersteds}
end

#activity
Unit.define!('katal') do |katal|
  katal.definition  = Unit('1 mole/sec')
  katal.aliases     = %w{kat katal}
end

Unit.define('unit') do |unit|
  unit.definition   = Unit('1/60 microkatal')
  unit.aliases      = %w{U enzUnit}
end

#frequency

Unit.define('hertz') do |hz|
  hz.definition   = Unit('1 1/s')
  hz.aliases      = %w{Hz hertz}
end

#angle
Unit.define('degree') do |deg|
  deg.definition    = Unit(Math::PI / 180.0, 'radian')
  deg.aliases       = %w{deg degree degrees}
end

Unit.define('grad') do |grad|
  grad.definition   = Unit(Math::PI / 200.0, 'radian')
  grad.aliases      = %w{grad gradian grads}
end

#rotation
Unit.define!('rotation') do |rotation|
  rotation.definition = Unit(2.0*Math::PI, 'radian')
end

Unit.define('rpm') do |rpm|
  rpm.definition  = Unit('1 rotation/min')
end

#memory
Unit.define('bit') do |bit|
  bit.definition  = Unit('1/8 byte')
  bit.aliases     = %w{b bit}
end

#currency
Unit.define('cents') do |cents|
  cents.definition  = Unit('1/100 dollar')
end

#luminosity
Unit.define!('lumen') do |lumen|
  lumen.definition  = Unit('1 cd*steradian')
  lumen.aliases     = %w{lm lumen}
end

Unit.define('lux') do |lux|
  lux.definition  = Unit('1 lumen/m^2')
end

#radiation
Unit.define('gray') do |gray|
  gray.definition = Unit('1 J/kg')
  gray.aliases    = %w{Gy gray grays}
end

Unit.define('roentgen') do |roentgen|
  roentgen.definition = Unit('2.58e-4 C/kg')
  roentgen.aliases    = %w{R roentgen}
end

Unit.define('sievert') do |sievert|
  sievert.definition  = Unit('1 J/kg')
  sievert.aliases     = %w{Sv sievert sieverts}
end

Unit.define!('becquerel') do |becquerel|
  becquerel.definition  = Unit('1 1/s')
  becquerel.aliases     = %w{Bq becquerel becquerels}
end

Unit.define('curie') do |curie|
  curie.definition  = Unit('37 GBq')
  curie.aliases     = %w{Ci curie curies}
end

Unit.define!('count') do |count|
  count.definition  = Unit('1 each')
  count.kind        = :counting
end

# rate
Unit.define('cpm') do |cpm|
  cpm.definition  = Unit('1 count/min')
end

Unit.define('dpm') do |dpm|
  dpm.definition  = Unit('1 count/min')
end

Unit.define('bpm') do |bpm|
  bpm.definition  = Unit('1 count/min')
end

# misc
Unit.define!('dozen') do |dozen|
  dozen.definition  = Unit('12 each')
  dozen.aliases     = %w{doz dz dozen}
  dozen.kind       = :counting
end

Unit.define('gross') do |gross|
  gross.definition  = Unit('12 dozen')
  gross.aliases     = %w{gr gross}
  gross.kind       = :counting
end

Unit.define('cell') do |cell|
  cell.definition   = Unit('1 each')
  cell.aliases      = %w{cells cell}
  cell.kind         = :counting
end

Unit.define('base-pair') do |bp|
  bp.definition   = Unit('1 each')
  bp.aliases      = %w{bp base-pair}
  bp.kind         = :counting
end

Unit.define('nucleotide') do |nt|
  nt.definition   = Unit('1 each')
  nt.aliases      = %w{nt}
  nt.kind         = :counting
end

Unit.define('molecule') do |molecule|
  molecule.definition   = Unit('1 each')
  molecule.aliases      = %w{molecule molecules}
  molecule.kind         = :counting
end

Unit.define('percent') do |percent|
  percent.definition  = Unit('1/100')
  percent.aliases     = %w{% percent}
end

Unit.define('ppm') do |ppm|
  ppm.definition  = Unit(1) / 1_000_000
end

Unit.define('ppb') do |ppb|
  ppb.definition  = Unit(1) / 1_000_000_000
end