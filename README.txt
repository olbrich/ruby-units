=Ruby Units

Kevin C. Olbrich, Ph.D. 

kevin.olbrich@gmail.com

http://www.sciwerks.com

Project page: http://ruby-units.rubyforge.org/ruby-units

==Introduction
Many technical applications make use of specialized calculations at some point.  
Frequently, these calculations require unit conversions to ensure accurate results.  
Needless to say, this is a pain to properly keep track of, and is prone to numerous errors.
  
==Solution
The 'Ruby units' gem is designed so simplify the handling of units for scientific calculations. 
The units of each quantity are specified when a Unit object is created and the Unit class will 
handle all subsequent conversions and manipulations to ensure an accurate result.
  
==Installation:
This package may be installed using:
 gem install ruby-units
  
==Usage:
 unit = Unit.new("1")             # constant only
 unit = Unit.new("mm")            # unit only (defaults to a value of 1)
 unit = Unit.new("1 mm")          # create a simple unit
 unit = Unit.new("1 mm/s")        # a compound unit
 unit = Unit.new("1 mm s^-1")     # in exponent notation
 unit = Unit.new("1 kg*m^2/s^2")  # complex unit
 unit = Unit.new("1 kg m^2 s^-2") # complex unit
 unit = Unit("1 mm")              # shorthand
 unit = "1 mm".to_unit            # convert string object
 unit = object.to_unit            # convert any object using object.to_s
 unit = U'1 mm'
 unit = u'1 mm'
 unit = '1 mm'.unit
 unit = '1 mm'.u
 unit = '1/4 cup'.unit            # Rational number 
 unit = '1+1i mm'.unit            # Complex Number

==Rules:  
1. only 1 quantity per unit (with 2 exceptions... 6'5" and '8 lbs 8 oz')
2. use SI notation when possible
3. avoid using spaces in unit names

==Unit compatability:
Many methods require that the units of two operands are compatible.  Compatible units are those that can be easily converted into each other, such as 'meters' and 'feet'.

 unit1 =~ unit2   #=> true if units are compatible

==Unit Math:

<b>Method</b>::  <b>Comment</b>
 Unit#+()::       Add. only works if units are compatible
 Unit#-()::       Subtract. only works if units are compatible
 Unit#*()::       Multiply.  
 Unit#/()::       Divide.
 Unit#**()::      Exponentiate.  Exponent must be an integer, can be positive,  negative, or zero                        
 Unit#inverse:: Returns 1/unit
 Unit#abs::     Returns absolute value of the unit quantity.  Strips off the  units
 Unit#ceil::    rounds quantity to next highest integer
 Unit#floor::   rounds quantity down to next lower integer
 Unit#round::   rounds quantity to nearest integer
 Unit#to_int::  returns the quantity as an integer
 
Unit will coerce other objects into a Unit if used in a formula.  This means that ..
 
 Unit("1 mm") + "2 mm"  == Unit("3 mm")
 
This will work as expected so long as you start the formula with a Unit object. 

==Conversions & comparisons

Units can be converted to other units in a couple of ways.

 unit1 = unit >> "ft"   # => convert to 'feet'
 unit >>= "ft"          # => convert and overwrite original object
 unit3 = unit1 + unit2  # => resulting object will have the units of unit1
 unit3 = unit1 - unit2  # => resulting object will have the units of unit1
 unit1 <=> unit2        # => does comparison on quantities in base units, 
                          throws an exception if not compatible
 unit1 === unit2        # => true if units and quantity are the same, even if
                          'equivalent' by <=>
 unit.to('ft')          # convert
 unit1 + unit2 >> "ft"  # converts result of math to 'ft'
 (unit1 + unit2).to('ft') # converts result to 'ft'
 
Any object that defines a 'to_unit' method will be automatically coerced to a unit during calculations.
 
==Text Output
Units will display themselves nicely based on the preferred abbreviation for the units and prefixes.
Since Unit implements a Unit#to_s, all that is needed in most cases is:
 "#{Unit.new('1 mm')}"  #=> "1 mm"
 
The to_s also accepts some options.
 Unit.new('1.5 mm').to_s("%0.2f")  # => "1.50 mm".  Enter any valid format
                                      string.  Also accepts strftime format
 U('1.5 mm').to_s("in")     # => converts to inches before printing
 U("2 m").to_s(:ft)         #=> returns 6'7"
 U("100 kg").to_s(:lbs)     #=> returns 220 lbs, 7 oz
 
 
==Time Helpers

Time, Date, and DateTime objects can have time units added or subtracted.

Time.now + "10 min".unit 

Several helpers have also been defined.
Note: If you include the 'Chronic' gem, you can specify times in natural
      language.

 'min'.since('9/18/06 3:00pm')
 'min'.before('9/18/08 3:00pm')
 'days'.until('1/1/07')
 '5 min'.from(Time.now)
 '5 min'.from_now
 '5 min'.before_now
 '5 min'.before(Time.now)
 '10 min'.ago

Durations may be entered as 'HH:MM:SS, usec' and will be returned in 'hours'.

 '1:00'.unit #=> 1 h
 '0:30'.unit #=> 0.5 h
 '0:30:30'.unit #=> 0.5 h + 30 sec

If only one ":" is present, it is interpreted as the separator between hours and minutes.

==Ranges

 [U('0 h')..U('10 h')].each {|x| p x}
works so long as the starting point has an integer scalar

==Math functions
All Trig math functions (sin, cos, sinh, hypot...) can take a unit as their parameter.  
It will be converted to radians and then used if possible.

==Temperatures
Ruby-units makes a distinction between a temperature (which technically is a property) and 
degrees of temperature (which temperatures are measured in).

Temperature units (i.e., 'tempK') can be converted back and forth, and will take into account 
the differences in the zero points of the various scales. Differential temperature (e.g., '100 degC'.unit) 
units behave like most other units.

 '37 tempC'.unit >> 'tempF' #=> 98.6 tempF

Ruby-units will raise an exception if you attempt to create a temperature unit that would 
fall below absolute zero.

Unit math on temperatures is fairly limited.  

 '100 tempC'.unit + '10 degC'.unit   #=> '110 tempC'.unit
 '100 tempC'.unit - '10 degC'.unit   #=> '90 tempC'.unit
 '100 tempC'.unit + '50 tempC'.unit  #=> exception  
 '100 tempC'.unit - '50 tempC'.unit  #=> '50 degC'.unit
 '50 tempC'.unit - '100 tempC'.unit  #=> '-50 degC'.unit
 '100 tempC'.unit * [scalar]         #=> '100*scalar tempC'.unit
 '100 tempC'.unit / [scalar]         #=> '100/scalar tempC'.unit
 '100 tempC'.unit * [unit]           #=> exception
 '100 tempC'.unit / [unit]           #=> exception
 '100 tempC'.unit ** N               #=> exception

 '100 tempC'.unit >> 'degC'          #=> '100 degC'.unit   
This conversion references the 0 point on the scale of the temperature unit 

 '100 degC'.unit >> 'tempC'          #=> '-173 tempC'.unit
These conversions are always interpreted as being relative to absolute zero.
Conversions are probably better done like this...
 '0 tempC'.unit + '100 degC'.unit #=> '100 tempC'.unit

