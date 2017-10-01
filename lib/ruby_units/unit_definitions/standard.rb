# length units

RubyUnits::Unit.define('inch') do |inch|
  inch.definition = RubyUnits::Unit.new('254/10000 meter')
  inch.aliases    = %w[in inch inches "]
end

RubyUnits::Unit.define('foot') do |foot|
  foot.definition = RubyUnits::Unit.new('12 inches')
  foot.aliases    = %w[ft foot feet ']
end

RubyUnits::Unit.define('survey-foot') do |sft|
  sft.definition = RubyUnits::Unit.new('1200/3937 meter')
  sft.aliases    = %w[sft sfoot sfeet]
end

RubyUnits::Unit.define('yard') do |yard|
  yard.definition = RubyUnits::Unit.new('3 ft')
  yard.aliases    = %w[yd yard yards]
end

RubyUnits::Unit.define('mile') do |mile|
  mile.definition = RubyUnits::Unit.new('5280 ft')
  mile.aliases    = %w[mi mile miles]
end

RubyUnits::Unit.define('naut-mile') do |naut|
  naut.definition = RubyUnits::Unit.new('1852 m')
  naut.aliases    = %w[nmi M NM]
end

# on land
RubyUnits::Unit.define('league') do |league|
  league.definition = RubyUnits::Unit.new('3 miles')
  league.aliases    = %w[league leagues]
end

# at sea
RubyUnits::Unit.define('naut-league') do |naut_league|
  naut_league.definition = RubyUnits::Unit.new('3 nmi')
  naut_league.aliases    = %w[nleague nleagues]
end

RubyUnits::Unit.define('furlong') do |furlong|
  furlong.definition = RubyUnits::Unit.new('1/8 mile')
  furlong.aliases    = %w[fur furlong furlongs]
end

RubyUnits::Unit.define('rod') do |rod|
  rod.definition  = RubyUnits::Unit.new('33/2 feet')
  rod.aliases     = %w[rd rod rods]
end

RubyUnits::Unit.define('fathom') do |fathom|
  fathom.definition = RubyUnits::Unit.new('6 ft')
  fathom.aliases    = %w[fathom fathoms]
end

RubyUnits::Unit.define('mil') do |mil|
  mil.definition = RubyUnits::Unit.new('1/1000 inch')
  mil.aliases    = %w[mil mils]
end

RubyUnits::Unit.define('angstrom') do |ang|
  ang.definition = RubyUnits::Unit.new('1/10 nm')
  ang.aliases    = %w[ang angstrom angstroms]
end

# typesetting

RubyUnits::Unit.define('pica') do |pica|
  pica.definition = RubyUnits::Unit.new('1/72 ft')
  pica.aliases    = %w[P pica picas]
end

RubyUnits::Unit.define('point') do |point|
  point.definition = RubyUnits::Unit.new('1/12 pica')
  point.aliases    = %w[point points]
end

RubyUnits::Unit.define('dot') do |dot|
  dot.definition  = RubyUnits::Unit.new('1 each')
  dot.aliases     = %w[dot dots]
  dot.kind        = :counting
end

RubyUnits::Unit.define('pixel') do |pixel|
  pixel.definition  = RubyUnits::Unit.new('1 each')
  pixel.aliases     = %w[px pixel pixels]
  pixel.kind        = :counting
end

RubyUnits::Unit.define('ppi') do |ppi|
  ppi.definition  = RubyUnits::Unit.new('1 pixel/inch')
end

RubyUnits::Unit.define('dpi') do |dpi|
  dpi.definition  = RubyUnits::Unit.new('1 dot/inch')
end

# Mass

avagadro_constant = RubyUnits::Unit.new('6.02214129e23 1/mol')

RubyUnits::Unit.define('AMU') do |amu|
  amu.definition = RubyUnits::Unit.new('0.012 kg/mol') / (12 * avagadro_constant)
  amu.aliases    = %w[u AMU amu]
end

RubyUnits::Unit.define('dalton') do |dalton|
  dalton.definition = RubyUnits::Unit.new('1 amu')
  dalton.aliases    = %w[Da dalton daltons]
end

RubyUnits::Unit.define('metric-ton') do |mton|
  mton.definition = RubyUnits::Unit.new('1000 kg')
  mton.aliases    = %w[tonne]
end

# defined as a rational number to preserve accuracy and minimize round-off errors during
# calculations
RubyUnits::Unit.define('pound') do |pound|
  pound.definition = RubyUnits::Unit.new(Rational(45_359_237, 1e8), 'kg')
  pound.aliases    = %w[lbs lb lbm pound-mass pound pounds #]
end

RubyUnits::Unit.define('ounce') do |ounce|
  ounce.definition = RubyUnits::Unit.new('1/16 lbs')
  ounce.aliases    = %w[oz ounce ounces]
end

RubyUnits::Unit.define('gram') do |gram|
  gram.definition = RubyUnits::Unit.new('1/1000 kg')
  gram.aliases    = %w[g gram grams gramme grammes]
end

RubyUnits::Unit.define('short-ton') do |ton|
  ton.definition = RubyUnits::Unit.new('2000 lbs')
  ton.aliases    = %w[tn ton tons short-tons]
end

RubyUnits::Unit.define('carat') do |carat|
  carat.definition = RubyUnits::Unit.new('1/5000 kg')
  carat.aliases    = %w[ct carat carats]
end

RubyUnits::Unit.define('stone') do |stone|
  stone.definition = RubyUnits::Unit.new('14 lbs')
  stone.aliases    = %w[st stone]
end

# time

RubyUnits::Unit.define('minute') do |min|
  min.definition = RubyUnits::Unit.new('60 seconds')
  min.aliases    = %w[min minute minutes]
end

RubyUnits::Unit.define('hour') do |hour|
  hour.definition = RubyUnits::Unit.new('60 minutes')
  hour.aliases    = %w[h hr hrs hour hours]
end

RubyUnits::Unit.define('day') do |day|
  day.definition  = RubyUnits::Unit.new('24 hours')
  day.aliases     = %w[d day days]
end

RubyUnits::Unit.define('week') do |week|
  week.definition   = RubyUnits::Unit.new('7 days')
  week.aliases      = %w[wk week weeks]
end

RubyUnits::Unit.define('fortnight') do |fortnight|
  fortnight.definition  = RubyUnits::Unit.new('2 weeks')
  fortnight.aliases     = %w[fortnight fortnights]
end

RubyUnits::Unit.define('year') do |year|
  year.definition = RubyUnits::Unit.new('31556926 seconds') # works out to 365.24219907407405 days
  year.aliases    = %w[y yr year years annum]
end

RubyUnits::Unit.define('decade') do |decade|
  decade.definition = RubyUnits::Unit.new('10 years')
  decade.aliases    = %w[decade decades]
end

RubyUnits::Unit.define('century') do |century|
  century.definition  = RubyUnits::Unit.new('100 years')
  century.aliases     = %w[century centuries]
end

# area

RubyUnits::Unit.define('hectare') do |hectare|
  hectare.definition = RubyUnits::Unit.new('10000 m^2')
end

RubyUnits::Unit.define('acre') do |acre|
  acre.definition = RubyUnits::Unit.new('1 mi')**2 / 640
  acre.aliases    = %w[acre acres]
end

RubyUnits::Unit.define('sqft') do |sqft|
  sqft.definition = RubyUnits::Unit.new('1 ft^2')
end

RubyUnits::Unit.define('sqin') do |sqin|
  sqin.definition = RubyUnits::Unit.new('1 in^2')
end

# volume

RubyUnits::Unit.define('liter') do |liter|
  liter.definition = RubyUnits::Unit.new('1/1000 m^3')
  liter.aliases    = %w[l L liter liters litre litres]
end

RubyUnits::Unit.define('gallon') do |gallon|
  gallon.definition = RubyUnits::Unit.new('231 in^3')
  gallon.aliases    = %w[gal gallon gallons]
end

RubyUnits::Unit.define('quart') do |quart|
  quart.definition  = RubyUnits::Unit.new('1/4 gal')
  quart.aliases     = %w[qt quart quarts]
end

RubyUnits::Unit.define('pint') do |pint|
  pint.definition = RubyUnits::Unit.new('1/8 gal')
  pint.aliases    = %w[pt pint pints]
end

RubyUnits::Unit.define('cup') do |cup|
  cup.definition = RubyUnits::Unit.new('1/16 gal')
  cup.aliases    = %w[cu cup cups]
end

RubyUnits::Unit.define('fluid-ounce') do |floz|
  floz.definition = RubyUnits::Unit.new('1/128 gal')
  floz.aliases    = %w[floz fluid-ounce fluid-ounces]
end

RubyUnits::Unit.define('tablespoon') do |tbsp|
  tbsp.definition = RubyUnits::Unit.new('1/2 floz')
  tbsp.aliases    = %w[tbs tbsp tablespoon tablespoons]
end

RubyUnits::Unit.define('teaspoon') do |tsp|
  tsp.definition = RubyUnits::Unit.new('1/3 tablespoon')
  tsp.aliases    = %w[tsp teaspoon teaspoons]
end

##
# The board-foot is a specialized unit of measure for the volume of lumber in
# the United States and Canada. It is the volume of a one-foot length of a board
# one foot wide and one inch thick.
# http://en.wikipedia.org/wiki/Board_foot
RubyUnits::Unit.define('bdft') do |bdft|
  bdft.definition = RubyUnits::Unit.new('1/12 ft^3')
  bdft.aliases    = %w[fbm boardfoot boardfeet bf]
end

# volumetric flow

RubyUnits::Unit.define('cfm') do |cfm|
  cfm.definition = RubyUnits::Unit.new('1 ft^3/minute')
  cfm.aliases    = %w[cfm CFM CFPM]
end

# speed

RubyUnits::Unit.define('kph') do |kph|
  kph.definition  = RubyUnits::Unit.new('1 kilometer/hour')
end

RubyUnits::Unit.define('mph') do |mph|
  mph.definition  = RubyUnits::Unit.new('1 mile/hour')
end

RubyUnits::Unit.define('fps') do |fps|
  fps.definition  = RubyUnits::Unit.new('1 foot/second')
end

RubyUnits::Unit.define('knot') do |knot|
  knot.definition   = RubyUnits::Unit.new('1 nmi/hour')
  knot.aliases      = %w[kt kn kts knot knots]
end

RubyUnits::Unit.define('gee') do |gee|
  # approximated as a rational number to minimize round-off errors
  gee.definition    = RubyUnits::Unit.new(Rational(196_133, 20_000), 'm/s^2') # equivalent to 9.80665 m/s^2
  gee.aliases       = %w[gee standard-gravitation]
end

# temperature differences

RubyUnits::Unit.define('newton') do |newton|
  newton.definition = RubyUnits::Unit.new('1 kg*m/s^2')
  newton.aliases    = %w[N newton newtons]
end

RubyUnits::Unit.define('dyne') do |dyne|
  dyne.definition = RubyUnits::Unit.new('1/100000 N')
  dyne.aliases    = %w[dyn dyne]
end

RubyUnits::Unit.define('pound-force') do |lbf|
  lbf.definition  = RubyUnits::Unit.new('1 lb') * RubyUnits::Unit.new('1 gee')
  lbf.aliases     = %w[lbf pound-force]
end

RubyUnits::Unit.define('poundal') do |poundal|
  poundal.definition  = RubyUnits::Unit.new('1 lb') * RubyUnits::Unit.new('1 ft/s^2')
  poundal.aliases     = %w[pdl poundal poundals]
end

temp_convert_factor = Rational(2_501_999_792_983_609, 4_503_599_627_370_496) # approximates 1/1.8

RubyUnits::Unit.define('celsius') do |celsius|
  celsius.definition  = RubyUnits::Unit.new('1 degK')
  celsius.aliases     = %w[degC celsius centigrade]
end

RubyUnits::Unit.define('fahrenheit') do |fahrenheit|
  fahrenheit.definition = RubyUnits::Unit.new(temp_convert_factor, 'degK')
  fahrenheit.aliases    = %w[degF fahrenheit]
end

RubyUnits::Unit.define('rankine') do |rankine|
  rankine.definition  = RubyUnits::Unit.new('1 degF')
  rankine.aliases     = %w[degR rankine]
end

RubyUnits::Unit.define('tempC') do |temp_c|
  temp_c.definition  = RubyUnits::Unit.new('1 tempK')
end

RubyUnits::Unit.define('tempF') do |temp_f|
  temp_f.definition  = RubyUnits::Unit.new(temp_convert_factor, 'tempK')
end

RubyUnits::Unit.define('tempR') do |temp_r|
  temp_r.definition  = RubyUnits::Unit.new('1 tempF')
end

# astronomy

speed_of_light = RubyUnits::Unit.new('299792458 m/s')

RubyUnits::Unit.define('light-second') do |ls|
  ls.definition = RubyUnits::Unit.new('1 s') * speed_of_light
  ls.aliases    = %w[ls lsec light-second]
end

RubyUnits::Unit.define('light-minute') do |lmin|
  lmin.definition = RubyUnits::Unit.new('1 min') * speed_of_light
  lmin.aliases    = %w[lmin light-minute]
end

RubyUnits::Unit.define('light-year') do |ly|
  ly.definition = RubyUnits::Unit.new('1 y') * speed_of_light
  ly.aliases    = %w[ly light-year]
end

RubyUnits::Unit.define('parsec') do |parsec|
  parsec.definition = RubyUnits::Unit.new('3.26163626 ly')
  parsec.aliases    = %w[pc parsec parsecs]
end

# once was '149597900000 m' but there appears to be a more accurate estimate according to wikipedia
# see http://en.wikipedia.org/wiki/Astronomical_unit
RubyUnits::Unit.define('AU') do |au|
  au.definition = RubyUnits::Unit.new('149597870700 m')
  au.aliases    = %w[AU astronomical-unit]
end

RubyUnits::Unit.define('redshift') do |red|
  red.definition = RubyUnits::Unit.new('1.302773e26 m')
  red.aliases    = %w[z red-shift]
end

# mass

RubyUnits::Unit.define('slug') do |slug|
  slug.definition = RubyUnits::Unit.new('1 lbf*s^2/ft')
  slug.aliases    = %w[slug slugs]
end

# pressure

RubyUnits::Unit.define('pascal') do |pascal|
  pascal.definition = RubyUnits::Unit.new('1 kg/m*s^2')
  pascal.aliases    = %w[Pa pascal pascals]
end

RubyUnits::Unit.define('bar') do |bar|
  bar.definition  = RubyUnits::Unit.new('100 kPa')
  bar.aliases     = %w[bar bars]
end

RubyUnits::Unit.define('atm') do |atm|
  atm.definition  = RubyUnits::Unit.new('101325 Pa')
  atm.aliases     = %w[atm ATM atmosphere atmospheres]
end

RubyUnits::Unit.define('mmHg') do |mmhg|
  density_of_mercury  = RubyUnits::Unit.new('7653360911758079/562949953421312 g/cm^3') # 13.5951 g/cm^3 at 0 tempC
  mmhg.definition     = RubyUnits::Unit.new('1 mm') * RubyUnits::Unit.new('1 gee') * density_of_mercury
end

RubyUnits::Unit.define('inHg') do |inhg|
  density_of_mercury = RubyUnits::Unit.new('7653360911758079/562949953421312 g/cm^3') # 13.5951 g/cm^3 at 0 tempC
  inhg.definition    = RubyUnits::Unit.new('1 in') * RubyUnits::Unit.new('1 gee') * density_of_mercury
end

RubyUnits::Unit.define('torr') do |torr|
  torr.definition = RubyUnits::Unit.new('1/760 atm')
  torr.aliases    = %w[Torr torr]
end

RubyUnits::Unit.define('psi') do |psi|
  psi.definition  = RubyUnits::Unit.new('1 lbf/in^2')
end

RubyUnits::Unit.define('cmh2o') do |cmh2o|
  density_of_water  = RubyUnits::Unit.new('1 g/cm^3') # at 4 tempC
  cmh2o.definition  = RubyUnits::Unit.new('1 cm') * RubyUnits::Unit.new('1 gee') * density_of_water
  cmh2o.aliases     = %w[cmH2O cmh2o cmAq]
end

RubyUnits::Unit.define('inh2o') do |inh2o|
  density_of_water  = RubyUnits::Unit.new('1 g/cm^3') # at 4 tempC
  inh2o.definition  = RubyUnits::Unit.new('1 in') * RubyUnits::Unit.new('1 gee') * density_of_water
  inh2o.aliases     = %w[inH2O inh2o inAq]
end

# viscosity

RubyUnits::Unit.define('poise') do |poise|
  poise.definition  = RubyUnits::Unit.new('dPa*s')
  poise.aliases     = %w[P poise]
end

RubyUnits::Unit.define('stokes') do |stokes|
  stokes.definition = RubyUnits::Unit.new('1 cm^2/s')
  stokes.aliases    = %w[St stokes]
end

# #energy

RubyUnits::Unit.define('joule') do |joule|
  joule.definition  = RubyUnits::Unit.new('1 N*m')
  joule.aliases     = %w[J joule joules]
end

RubyUnits::Unit.define('erg') do |erg|
  erg.definition  = RubyUnits::Unit.new('1 g*cm^2/s^2')
  erg.aliases     = %w[erg ergs]
end

# power

RubyUnits::Unit.define('watt') do |watt|
  watt.definition = RubyUnits::Unit.new('1 N*m/s')
  watt.aliases    = %w[W Watt watt watts]
end

RubyUnits::Unit.define('horsepower') do |hp|
  hp.definition = RubyUnits::Unit.new('33000 ft*lbf/min')
  hp.aliases    = %w[hp horsepower]
end

# energy
RubyUnits::Unit.define('btu') do |btu|
  btu.definition  = RubyUnits::Unit.new('2320092679909671/2199023255552 J') # 1055.056 J  --- ISO standard
  btu.aliases     = %w[Btu btu Btus btus]
end

RubyUnits::Unit.define('therm') do |therm|
  therm.definition  = RubyUnits::Unit.new('100 kBtu')
  therm.aliases     = %w[thm therm therms Therm]
end

# "small" calorie
RubyUnits::Unit.define('calorie') do |calorie|
  calorie.definition  = RubyUnits::Unit.new('4.184 J')
  calorie.aliases     = %w[cal calorie calories]
end

# "big" calorie
RubyUnits::Unit.define('Calorie') do |calorie|
  calorie.definition  = RubyUnits::Unit.new('1 kcal')
  calorie.aliases     = %w[Cal Calorie Calories]
end

RubyUnits::Unit.define('molar') do |molar|
  molar.definition  = RubyUnits::Unit.new('1 mole/l')
  molar.aliases     = %w[M molar]
end

# potential
RubyUnits::Unit.define('volt') do |volt|
  volt.definition = RubyUnits::Unit.new('1 W/A')
  volt.aliases    = %w[V volt volts]
end

# capacitance
RubyUnits::Unit.define('farad') do |farad|
  farad.definition  = RubyUnits::Unit.new('1 A*s/V')
  farad.aliases     = %w[F farad farads]
end

# charge
RubyUnits::Unit.define('coulomb') do |coulomb|
  coulomb.definition  = RubyUnits::Unit.new('1 A*s')
  coulomb.aliases     = %w[C coulomb coulombs]
end

# conductance
RubyUnits::Unit.define('siemens') do |siemens|
  siemens.definition  = RubyUnits::Unit.new('1 A/V')
  siemens.aliases     = %w[S siemens]
end

# inductance
RubyUnits::Unit.define('henry') do |henry|
  henry.definition  = RubyUnits::Unit.new('1 J/A^2')
  henry.aliases     = %w[H henry henries]
end

# resistance
RubyUnits::Unit.define('ohm') do |ohm|
  ohm.definition  = RubyUnits::Unit.new('1 V/A')
  ohm.aliases     = %w[Ohm ohm ohms]
end

# magnetism

RubyUnits::Unit.define('weber') do |weber|
  weber.definition  = RubyUnits::Unit.new('1 V*s')
  weber.aliases     = %w[Wb weber webers]
end

RubyUnits::Unit.define('tesla') do |tesla|
  tesla.definition  = RubyUnits::Unit.new('1 V*s/m^2')
  tesla.aliases     = %w[T tesla teslas]
end

RubyUnits::Unit.define('gauss') do |gauss|
  gauss.definition  = RubyUnits::Unit.new('100 microT')
  gauss.aliases     = %w[G gauss]
end

RubyUnits::Unit.define('maxwell') do |maxwell|
  maxwell.definition  = RubyUnits::Unit.new('1 gauss*cm^2')
  maxwell.aliases     = %w[Mx maxwell maxwells]
end

RubyUnits::Unit.define('oersted') do |oersted|
  oersted.definition  = RubyUnits::Unit.new(250.0 / Math::PI, 'A/m')
  oersted.aliases     = %w[Oe oersted oersteds]
end

# activity
RubyUnits::Unit.define('katal') do |katal|
  katal.definition  = RubyUnits::Unit.new('1 mole/sec')
  katal.aliases     = %w[kat katal]
end

RubyUnits::Unit.define('unit') do |unit|
  unit.definition   = RubyUnits::Unit.new('1/60 microkatal')
  unit.aliases      = %w[U enzUnit units]
end

# frequency

RubyUnits::Unit.define('hertz') do |hz|
  hz.definition   = RubyUnits::Unit.new('1 1/s')
  hz.aliases      = %w[Hz hertz]
end

# angle
RubyUnits::Unit.define('degree') do |deg|
  deg.definition    = RubyUnits::Unit.new(Math::PI / 180.0, 'radian')
  deg.aliases       = %w[deg degree degrees]
end

RubyUnits::Unit.define('gon') do |grad|
  grad.definition   = RubyUnits::Unit.new(Math::PI / 200.0, 'radian')
  grad.aliases      = %w[gon grad gradian grads]
end

# rotation
RubyUnits::Unit.define('rotation') do |rotation|
  rotation.definition = RubyUnits::Unit.new(2.0 * Math::PI, 'radian')
end

RubyUnits::Unit.define('rpm') do |rpm|
  rpm.definition  = RubyUnits::Unit.new('1 rotation/min')
end

# memory
RubyUnits::Unit.define('bit') do |bit|
  bit.definition  = RubyUnits::Unit.new('1/8 byte')
  bit.aliases     = %w[b bit]
end

# currency
RubyUnits::Unit.define('cents') do |cents|
  cents.definition  = RubyUnits::Unit.new('1/100 dollar')
end

# luminosity
RubyUnits::Unit.define('lumen') do |lumen|
  lumen.definition  = RubyUnits::Unit.new('1 cd*steradian')
  lumen.aliases     = %w[lm lumen]
end

RubyUnits::Unit.define('lux') do |lux|
  lux.definition  = RubyUnits::Unit.new('1 lumen/m^2')
end

# radiation
RubyUnits::Unit.define('gray') do |gray|
  gray.definition = RubyUnits::Unit.new('1 J/kg')
  gray.aliases    = %w[Gy gray grays]
end

RubyUnits::Unit.define('roentgen') do |roentgen|
  roentgen.definition = RubyUnits::Unit.new('2.58e-4 C/kg')
  roentgen.aliases    = %w[R roentgen]
end

RubyUnits::Unit.define('sievert') do |sievert|
  sievert.definition  = RubyUnits::Unit.new('1 J/kg')
  sievert.aliases     = %w[Sv sievert sieverts]
end

RubyUnits::Unit.define('becquerel') do |becquerel|
  becquerel.definition  = RubyUnits::Unit.new('1 1/s')
  becquerel.aliases     = %w[Bq becquerel becquerels]
end

RubyUnits::Unit.define('curie') do |curie|
  curie.definition  = RubyUnits::Unit.new('37 GBq')
  curie.aliases     = %w[Ci curie curies]
end

RubyUnits::Unit.define('count') do |count|
  count.definition  = RubyUnits::Unit.new('1 each')
  count.kind        = :counting
end

# rate
RubyUnits::Unit.define('cpm') do |cpm|
  cpm.definition  = RubyUnits::Unit.new('1 count/min')
end

RubyUnits::Unit.define('dpm') do |dpm|
  dpm.definition  = RubyUnits::Unit.new('1 count/min')
end

RubyUnits::Unit.define('bpm') do |bpm|
  bpm.definition  = RubyUnits::Unit.new('1 count/min')
end

# misc
RubyUnits::Unit.define('dozen') do |dozen|
  dozen.definition  = RubyUnits::Unit.new('12 each')
  dozen.aliases     = %w[doz dz dozen]
  dozen.kind = :counting
end

RubyUnits::Unit.define('gross') do |gross|
  gross.definition  = RubyUnits::Unit.new('12 dozen')
  gross.aliases     = %w[gr gross]
  gross.kind = :counting
end

RubyUnits::Unit.define('cell') do |cell|
  cell.definition   = RubyUnits::Unit.new('1 each')
  cell.aliases      = %w[cells cell]
  cell.kind         = :counting
end

RubyUnits::Unit.define('base-pair') do |bp|
  bp.definition   = RubyUnits::Unit.new('1 each')
  bp.aliases      = %w[bp base-pair]
  bp.kind         = :counting
end

RubyUnits::Unit.define('nucleotide') do |nt|
  nt.definition   = RubyUnits::Unit.new('1 each')
  nt.aliases      = %w[nt]
  nt.kind         = :counting
end

RubyUnits::Unit.define('molecule') do |molecule|
  molecule.definition   = RubyUnits::Unit.new('1 each')
  molecule.aliases      = %w[molecule molecules]
  molecule.kind         = :counting
end

RubyUnits::Unit.define('percent') do |percent|
  percent.definition  = RubyUnits::Unit.new('1/100')
  percent.aliases     = %w[% percent]
end

RubyUnits::Unit.define('ppm') do |ppm|
  ppm.definition  = RubyUnits::Unit.new(1) / 1_000_000
end

RubyUnits::Unit.define('ppb') do |ppb|
  ppb.definition  = RubyUnits::Unit.new(1) / 1_000_000_000
end
