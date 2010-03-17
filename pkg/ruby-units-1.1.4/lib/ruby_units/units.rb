

class Unit < Numeric
UNIT_DEFINITIONS = { 
  # prefixes
  '<googol>' => [%w{googol}, 1e100, :prefix],
  '<kibi>'  =>  [%w{Ki Kibi kibi}, 2**10, :prefix],
  '<mebi>'  =>  [%w{Mi Mebi mebi}, 2**20, :prefix],
  '<gibi>'  =>  [%w{Gi Gibi gibi}, 2**30, :prefix],
  '<tebi>'  =>  [%w{Ti Tebi tebi}, 2**40, :prefix],
  '<pebi>'  =>  [%w{Pi Pebi pebi}, 2**50, :prefix],
  '<exi>'   =>  [%w{Ei Exi exi}, 2**60, :prefix],
  '<zebi>'  =>  [%w{Zi Zebi zebi}, 2**70, :prefix],
  '<yebi>'  =>  [%w{Yi Yebi yebi}, 2**80, :prefix],
  '<yotta>' =>  [%w{Y Yotta yotta}, 1e24, :prefix],
  '<zetta>' =>  [%w{Z Zetta zetta}, 1e21, :prefix],
  '<exa>'   =>  [%w{E Exa exa}, 1e18, :prefix],
  '<peta>'  =>  [%w{P Peta peta}, 1e15, :prefix],
  '<tera>'  =>  [%w{T Tera tera}, 1e12, :prefix],
  '<giga>'  =>  [%w{G Giga giga}, 1e9, :prefix],
  '<mega>'  =>  [%w{M Mega mega}, 1e6, :prefix],
  '<kilo>'  =>  [%w{k kilo}, 1e3, :prefix],
  '<hecto>' =>  [%w{h Hecto hecto}, 1e2, :prefix],
  '<deca>'  =>  [%w{da Deca deca deka}, 1e1, :prefix],
  '<deci>'  =>  [%w{d Deci deci}, 1e-1, :prefix],
  '<centi>'  => [%w{c Centi centi}, 1e-2, :prefix],
  '<milli>' =>  [%w{m Milli milli}, 1e-3, :prefix],
  '<micro>'  => [%w{u Micro micro}, 1e-6, :prefix],
  '<nano>'  =>  [%w{n Nano nano}, 1e-9, :prefix],
  '<pico>'  =>  [%w{p Pico pico}, 1e-12, :prefix],
  '<femto>' =>  [%w{f Femto femto}, 1e-15, :prefix],
  '<atto>'  =>  [%w{a Atto atto}, 1e-18, :prefix],
  '<zepto>' =>  [%w{z Zepto zepto}, 1e-21, :prefix],
  '<yocto>' =>  [%w{y Yocto yocto}, 1e-24, :prefix],
  '<1>'     =>  [%w{1},1,:prefix],

  # length units
  '<meter>' =>  [%w{m meter meters metre metres}, 1.0, :length, %w{<meter>} ],
  '<inch>'  =>  [%w{in inch inches "}, 0.0254, :length, %w{<meter>}],
  '<foot>'  =>  [%w{ft foot feet '}, 0.3048, :length, %w{<meter>}],
  '<yard>'  =>  [%w{yd yard yards}, 0.9144, :length, %w{<meter>}],
  '<mile>'  =>  [%w{mi mile miles}, 1609.344, :length, %w{<meter>}],
  '<naut-mile>' => [%w{nmi}, 1852, :length, %w{<meter>}],
  '<league>'=>  [%w{league leagues}, 4828, :length, %w{<meter>}],
  '<furlong>'=> [%w{furlong furlongs}, 201.2, :length, %w{<meter>}],
  '<rod>'   =>  [%w{rd rod rods}, 5.029, :length, %w{<meter>}],
  '<mil>'   =>  [%w{mil mils}, 0.0000254, :length, %w{<meter>}],
  '<angstrom>'  =>[%w{ang angstrom angstroms}, 1e-10, :length, %w{<meter>}],
  '<fathom>' => [%w{fathom fathoms}, 1.829, :length, %w{<meter>}],  
  '<pica>'  => [%w{pica picas}, 0.004217, :length, %w{<meter>}],
  '<point>' => [%w{pt point points}, 0.0003514, :length, %w{<meter>}],
  '<redshift>' => [%w{z red-shift}, 1.302773e26, :length, %w{<meter>}],
  '<AU>'    => [%w{AU astronomical-unit}, 149597900000, :length, %w{<meter>}],
  '<light-second>'=>[%w{ls light-second}, 299792500, :length, %w{<meter>}],
  '<light-minute>'=>[%w{lmin light-minute}, 17987550000, :length, %w{<meter>}],
  '<light-year>' => [%w{ly light-year}, 9460528000000000, :length, %w{<meter>}],
  '<parsec>'  => [%w{pc parsec parsecs}, 30856780000000000, :length, %w{<meter>}],

  #mass
  '<kilogram>' => [%w{kg kilogram kilograms}, 1.0, :mass, %w{<kilogram>}],
  '<AMU>' => [%w{u AMU amu}, 6.0221415e26, :mass, %w{<kilogram>}],
  '<dalton>' => [%w{Da Dalton Daltons dalton daltons}, 6.0221415e26, :mass, %w{<kilogram>}],
  '<slug>' => [%w{slug slugs}, 14.5939029, :mass, %w{<kilogram>}],
  '<short-ton>' => [%w{tn ton}, 907.18474, :mass, %w{<kilogram>}],
  '<metric-ton>'=>[%w{tonne}, 1000, :mass, %w{<kilogram>}],
  '<carat>' => [%w{ct carat carats}, 0.0002, :mass, %w{<kilogram>}],
  '<pound>' => [%w{lbs lb pound pounds #}, 0.45359237, :mass, %w{<kilogram>}],
  '<ounce>' => [%w{oz ounce ounces}, 0.0283495231, :mass, %w{<kilogram>}],
  '<gram>'    =>  [%w{g gram grams gramme grammes},1e-3,:mass, %w{<kilogram>}],

  #area
  '<hectare>'=>[%w{hectare}, 10000, :area, %w{<meter> <meter>}],
  '<acre>'=>[%w(acre acres), 4046.85642, :area, %w{<meter> <meter>}],
  '<sqft>'=>[%w(sqft), 1, :area, %w{<feet> <feet>}],

  #volume
  '<liter>' => [%w{l L liter liters litre litres}, 0.001, :volume, %w{<meter> <meter> <meter>}],
  '<gallon>'=>  [%w{gal gallon gallons}, 0.0037854118, :volume, %w{<meter> <meter> <meter>}],
  '<quart>'=>  [%w{qt quart quarts}, 0.00094635295, :volume, %w{<meter> <meter> <meter>}],
  '<pint>'=>  [%w{pt pint pints}, 0.000473176475, :volume, %w{<meter> <meter> <meter>}],
  '<cup>'=>  [%w{cu cup cups}, 0.000236588238, :volume, %w{<meter> <meter> <meter>}],
  '<fluid-ounce>'=>  [%w{floz fluid-ounce}, 2.95735297e-5, :volume, %w{<meter> <meter> <meter>}],
  '<tablespoon>'=>  [%w{tbs tablespoon tablespoons}, 1.47867648e-5, :volume, %w{<meter> <meter> <meter>}],
  '<teaspoon>'=>  [%w{tsp teaspoon teaspoons}, 4.92892161e-6, :volume, %w{<meter> <meter> <meter>}],

  #speed
  '<kph>' => [%w{kph}, 0.277777778, :speed, %w{<meter>}, %w{<second>}],
  '<mph>' => [%w{mph}, 0.44704, :speed, %w{<meter>}, %w{<second>}],
  '<knot>' => [%w{kt kn kts knot knots}, 0.514444444, :speed, %w{<meter>}, %w{<second>}],
  '<fps>'  => [%w{fps}, 0.3048, :speed, %w{<meter>}, %w{<second>}],
  
  #acceleration
  '<gee>' => [%w{gee}, 9.80655, :acceleration, %w{<meter>}, %w{<second> <second>}],

  #temperature_difference
  '<kelvin>' => [%w{degK kelvin}, 1.0, :temperature, %w{<kelvin>}],
  '<celsius>' => [%w{degC celsius celsius centigrade}, 1.0, :temperature, %w{<kelvin>}],
  '<fahrenheit>' => [%w{degF fahrenheit}, 1/1.8, :temperature, %w{<kelvin>}],
  '<rankine>' => [%w{degR rankine}, 1/1.8, :temperature, %w{<kelvin>}],
  '<temp-K>'  => [%w{tempK}, 1.0, :temperature, %w{<temp-K>}],
  '<temp-C>'  => [%w{tempC}, 1.0, :temperature, %w{<temp-K>}],
  '<temp-F>'  => [%w{tempF}, 1/1.8, :temperature, %w{<temp-K>}],
  '<temp-R>'  => [%w{tempR}, 1/1.8, :temperature, %w{<temp-K>}],
  
  #time
  '<second>'=>  [%w{s sec second seconds}, 1.0, :time, %w{<second>}],
  '<minute>'=>  [%w{min minute minutes}, 60.0, :time, %w{<second>}],  
  '<hour>'=>  [%w{h hr hrs hour hours}, 3600.0, :time, %w{<second>}],  
  '<day>'=>  [%w{d day days}, 3600*24, :time, %w{<second>}],
  '<week>'=>  [%w{wk week weeks}, 7*3600*24, :time, %w{<second>}],
  '<fortnight>'=> [%w{fortnight fortnights}, 1209600, :time, %W{<second>}],
  '<year>'=>  [%w{y yr year years annum}, 31556926, :time, %w{<second>}],
  '<decade>'=>[%w{decade decades}, 315569260, :time, %w{<second>}],
  '<century>'=>[%w{century centuries}, 3155692600, :time, %w{<second>}],

  #pressure
  '<pascal>' => [%w{Pa pascal Pascal}, 1.0, :pressure, %w{<kilogram>},%w{<meter> <second> <second>}],
  '<bar>' => [%w{bar bars}, 100000, :pressure, %w{<kilogram>},%w{<meter> <second> <second>}],
  '<mmHg>' => [%w{mmHg}, 133.322368,:pressure, %w{<kilogram>},%w{<meter> <second> <second>}],
  '<inHg>' => [%w{inHg}, 3386.3881472,:pressure, %w{<kilogram>},%w{<meter> <second> <second>}],
  '<torr>' => [%w{torr}, 133.322368,:pressure, %w{<kilogram>},%w{<meter> <second> <second>}],
  '<bar>' => [%w{bar}, 100000,:pressure, %w{<kilogram>},%w{<meter> <second> <second>}],
  '<atm>' => [%w{atm ATM atmosphere atmospheres}, 101325,:pressure, %w{<kilogram>},%w{<meter> <second> <second>}],
  '<psi>' => [%w{psi}, 6894.76,:pressure, %w{<kilogram>},%w{<meter> <second> <second>}],
  '<cmh2o>' => [%w{cmH2O}, 98.0638,:pressure, %w{<kilogram>},%w{<meter> <second> <second>}],
  '<inh2o>' => [%w{inH2O}, 249.082052,:pressure, %w{<kilogram>},%w{<meter> <second> <second>}],
  
  #viscosity
  '<poise>'  => [%w{P poise}, 0.1, :viscosity, %w{<kilogram>},%w{<meter> <second>} ],
  '<stokes>' => [%w{St stokes}, 1e-4, :viscosity, %w{<meter> <meter>}, %w{<second>}],

  #substance
  '<mole>'  =>  [%w{mol mole}, 1.0, :substance, %w{<mole>}],

  #concentration
  '<molar>' => [%w{M molar}, 1000, :concentration, %w{<mole>}, %w{<meter> <meter> <meter>}],
  '<wtpercent>'  => [%w{wt% wtpercent}, 10, :concentration, %w{<kilogram>}, %w{<meter> <meter> <meter>}],

  #activity
  '<katal>' =>  [%w{kat katal Katal}, 1.0, :activity, %w{<mole>}, %w{<second>}],
  '<unit>'  =>  [%w{U enzUnit}, 16.667e-16, :activity, %w{<mole>}, %w{<second>}],

  #capacitance
  '<farad>' =>  [%w{F farad Farad}, 1.0, :capacitance, %w{<farad>}],

  #charge
  '<coulomb>' =>  [%w{C coulomb Coulomb}, 1.0, :charge, %w{<ampere> <second>}],

  #current
  '<ampere>'  =>  [%w{A Ampere ampere amp amps}, 1.0, :current, %w{<ampere>}],

  #conductance
  '<siemens>' => [%w{S Siemens siemens}, 1.0, :resistance, %w{<second> <second> <second> <ampere> <ampere>}, %w{<kilogram> <meter> <meter>}],

  #inductance
  '<henry>' =>  [%w{H Henry henry}, 1.0, :inductance, %w{<meter> <meter> <kilogram>}, %w{<second> <second> <ampere> <ampere>}],

  #potential
  '<volt>'  =>  [%w{V Volt volt volts}, 1.0, :potential, %w{<meter> <meter> <kilogram>}, %w{<second> <second> <second> <ampere>}],

  #resistance
  '<ohm>' =>  [%w{Ohm ohm}, 1.0, :resistance, %w{<meter> <meter> <kilogram>},%w{<second> <second> <second> <ampere> <ampere>}],

  #magnetism
  '<weber>' => [%w{Wb weber webers}, 1.0, :magnetism, %w{<meter> <meter> <kilogram>}, %w{<second> <second> <ampere>}],
  '<tesla>'  => [%w{T tesla teslas}, 1.0, :magnetism, %w{<kilogram>}, %w{<second> <second> <ampere>}],
  '<gauss>' => [%w{G gauss}, 1e-4, :magnetism,  %w{<kilogram>}, %w{<second> <second> <ampere>}],
  '<maxwell>' => [%w{Mx maxwell maxwells}, 1e-8, :magnetism, %w{<meter> <meter> <kilogram>}, %w{<second> <second> <ampere>}],
  '<oersted>'  => [%w{Oe oersted oersteds}, 250.0/Math::PI, :magnetism, %w{<ampere>}, %w{<meter>}],

  #energy
  '<joule>' =>  [%w{J joule Joule joules}, 1.0, :energy, %w{<meter> <meter> <kilogram>}, %w{<second> <second>}],
  '<erg>'   =>  [%w{erg ergs}, 1e-7, :energy, %w{<meter> <meter> <kilogram>}, %w{<second> <second>}],
  '<btu>'   =>  [%w{BTU btu BTUs}, 1055.056, :energy, %w{<meter> <meter> <kilogram>}, %w{<second> <second>}],
  '<calorie>' =>  [%w{cal calorie calories}, 4.18400, :energy,%w{<meter> <meter> <kilogram>}, %w{<second> <second>}],
  '<Calorie>' =>  [%w{Cal Calorie Calories}, 4184.00, :energy,%w{<meter> <meter> <kilogram>}, %w{<second> <second>}],
  '<therm-US>' => [%w{th therm therms Therm}, 105480400, :energy,%w{<meter> <meter> <kilogram>}, %w{<second> <second>}],

  #force
  '<newton>'  => [%w{N Newton newton}, 1.0, :force, %w{<kilogram> <meter>}, %w{<second> <second>}],
  '<dyne>'  => [%w{dyn dyne}, 1e-5, :force, %w{<kilogram> <meter>}, %w{<second> <second>}],
  '<pound-force>'  => [%w{lbf pound-force}, 4.448222, :force, %w{<kilogram> <meter>}, %w{<second> <second>}],

  #frequency
  '<hertz>' => [%w{Hz hertz Hertz}, 1.0, :frequency, %w{<1>}, %{<second>}],

  #angle
  '<radian>' =>[%w{rad radian radian}, 1.0, :angle, %w{<radian>}],
  '<degree>' =>[%w{deg degree degrees}, Math::PI / 180.0, :angle, %w{<radian>}],
  '<grad>'   =>[%w{grad gradian grads}, Math::PI / 200.0, :angle, %w{<radian>}],
  '<steradian>'  => [%w{sr steradian steradians}, 1.0, :solid_angle, %w{<steradian>}],

  #rotation
  '<rotation>' => [%w{rotation}, 2.0*Math::PI, :angle, %w{<radian>}],
  '<rpm>'   =>[%w{rpm}, 2.0*Math::PI / 60.0, :angular_velocity, %w{<radian>}, %w{<second>}],

  #memory
  '<byte>'  =>[%w{B byte}, 1.0, :memory, %w{<byte>}],
  '<bit>'  =>[%w{b bit}, 0.125, :memory, %w{<byte>}],

  #currency
  '<dollar>'=>[%w{USD dollar}, 1.0, :currency, %w{<dollar>}],
  '<cents>' =>[%w{cents}, 0.01, :currency, %w{<dollar>}],

  #luminosity
  '<candela>' => [%w{cd candela}, 1.0, :luminosity, %w{<candela>}],
  '<lumen>' => [%w{lm lumen}, 1.0, :luminous_power, %w{<candela> <steradian>}],
  '<lux>' =>[%w{lux}, 1.0, :illuminance, %w{<candela> <steradian>}, %w{<meter> <meter>}],

  #power
  '<watt>'  => [%w{W watt watts}, 1.0, :power, %w{<kilogram> <meter> <meter>}, %w{<second> <second> <second>}],
  '<horsepower>'  =>  [%w{hp horsepower}, 745.699872, :power, %w{<kilogram> <meter> <meter>}, %w{<second> <second> <second>}],

  #radiation
  '<gray>' => [%w{Gy gray grays}, 1.0, :radiation, %w{<meter> <meter>}, %w{<second> <second>}],
  '<roentgen>' => [%w{R roentgen}, 0.009330, :radiation, %w{<meter> <meter>}, %w{<second> <second>}],
  '<sievert>' => [%w{Sv sievert sieverts}, 1.0, :radiation, %w{<meter> <meter>}, %w{<second> <second>}],
  '<becquerel>' => [%w{Bq bequerel bequerels}, 1.0, :radiation, %w{<1>},%w{<second>}],
  '<curie>' => [%w{Ci curie curies}, 3.7e10, :radiation, %w{<1>},%w{<second>}],
  
  # rate
  '<cpm>' => [%w{cpm}, 1.0/60.0, :rate, %w{<count>},%w{<second>}],
  '<dpm>' => [%w{dpm}, 1.0/60.0, :rate, %w{<count>},%w{<second>}],
  '<bpm>' => [%w{bpm}, 1.0/60.0, :rate, %w{<count>},%w{<second>}],

  #resolution / typography
  '<dot>' => [%w{dot dots}, 1, :resolution, %w{<each>}],
  '<pixel>' => [%w{pixel px}, 1, :resolution, %w{<each>}],
  '<ppi>' => [%w{ppi}, 1, :resolution, %w{<pixel>}, %w{<inch>}],
  '<dpi>' => [%w{dpi}, 1, :typography, %w{<dot>}, %w{<inch>}],
  '<pica>' => [%w{pica}, 0.00423333333 , :typography, %w{<meter>}],
  '<point>' => [%w{point pt}, 0.000352777778, :typography, %w{<meter>}],

  #other
  '<cell>' => [%w{cells cell}, 1, :counting, %w{<each>}],
  '<each>' => [%w{each}, 1.0, :counting, %w{<each>}],
  '<count>' => [%w{count}, 1.0, :counting, %w{<each>}],  
  '<base-pair>'  => [%w{bp}, 1.0, :counting, %w{<each>}],
  '<nucleotide>' => [%w{nt}, 1.0, :counting, %w{<each>}],
  '<molecule>' => [%w{molecule molecules}, 1.0, :counting, %w{<1>}],
  '<dozen>' =>  [%w{doz dz dozen},12.0,:prefix_only, %w{<each>}],
  '<percent>'=> [%w{% percent}, 0.01, :prefix_only, %w{<1>}],
  '<ppm>' =>  [%w{ppm},1e-6,:prefix_only, %w{<1>}],
  '<ppt>' =>  [%w{ppt},1e-9,:prefix_only, %w{<1>}],
  '<gross>' =>  [%w{gr gross},144.0, :prefix_only, %w{<dozen> <dozen>}],
  '<decibel>'  => [%w{dB decibel decibels}, 1.0, :logarithmic, %w{<decibel>}]


} # doc
end