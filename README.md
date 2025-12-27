# Ruby Units

Kevin C. Olbrich, Ph.D.

Project page:
[http://github.com/olbrich/ruby-units](http://github.com/olbrich/ruby-units)

## Introduction

Many technical applications make use of specialized calculations at some point.
Frequently, these calculations require unit conversions to ensure accurate
results. Needless to say, this is a pain to properly keep track of, and is prone
to numerous errors.

## Solution

The 'Ruby units' gem is designed to simplify the handling of units for
scientific calculations. The units of each quantity are specified when a Unit
object is created and the Unit class will handle all subsequent conversions and
manipulations to ensure an accurate result.

## Installation

This package requires Ruby 3.2 or later.

This package may be installed using:

```bash
gem install ruby-units
```

or add this to your `Gemfile`

```ruby
gem 'ruby-units'
```

## Usage

```ruby
unit = Unit.new("1")                 # constant only
unit = Unit.new("mm")                # unit only (defaults to a scalar of 1)
unit = Unit.new("1 mm")              # create a simple unit
unit = Unit.new("1 mm/s")            # a compound unit
unit = Unit.new("1 mm s^-1")         # in exponent notation
unit = Unit.new("1 kg*m^2/s^2")      # complex unit
unit = Unit.new("1 kg m^2 s^-2")     # complex unit
unit = Unit.new("1 mm")              # shorthand
unit = "1 mm".to_unit                # convert string object
unit = object.to_unit                # convert any object using object.to_s
unit = Unit.new('1/4 cup')           # Rational number
unit = Unit.new('1+1i mm')           # Complex Number
unit = Unit.new(scalar: 1.5, numerator: ["<meter>"], denominator: ["<second>"])  # keyword arguments
```

### Rules

1. only 1 quantity per unit (with 2 exceptions... 6'5" and '8 lbs 8 oz')
2. use SI notation when possible
3. spaces in units are allowed, but ones like '11/m' will be recognized as '11
   1/m'.

### Unit compatibility

Many methods require that the units of two operands are compatible. Compatible
units are those that can be easily converted into each other, such as 'meters'
and 'feet'.

```ruby
unit1 =~ unit2                  #=> true if units are compatible
unit1.compatible?(unit2)        #=> true if units are compatible
```

### Unit Math

```text
Unit#+()      # Add. only works if units are compatible
Unit#-()      # Subtract. only works if units are compatible
Unit#*()      # Multiply.
Unit#/()      # Divide.
Unit#**()     # Exponentiate.  Exponent must be an integer, can be positive,  negative, or zero
Unit#inverse  # Returns 1/unit
Unit#abs      # Returns absolute value of the unit quantity.  Units are preserved
Unit#ceil     # rounds quantity to next highest integer
Unit#floor    # rounds quantity down to next lower integer
Unit#round    # rounds quantity to nearest integer
Unit#truncate # truncates quantity to an integer
Unit#to_int   # returns the quantity as an integer
Unit#divmod   # divide and return quotient and remainder
Unit#remainder# returns remainder of division
Unit#quo      # returns quotient as a float or complex
```

Unit will coerce other objects into a Unit if used in a formula. This means...

```ruby
Unit.new("1 mm") + "2 mm"  == Unit.new("3 mm")
```

This will work as expected so long as you start the formula with a `Unit`
object.

### Conversions & Comparisons

Units can be converted to other units in a couple of ways.

```ruby
unit.convert_to('ft')             # convert
unit1 = unit >> "ft"              # convert to 'feet'
unit >>= "ft"                     # convert and overwrite original object
unit3 = unit1 + unit2             # resulting object will have the units of unit1
unit3 = unit1 - unit2             # resulting object will have the units of unit1
unit1 <=> unit2                   # does comparison on quantities in base units, throws an exception if not compatible
unit1 === unit2                   # true if units and quantity are the same, even if 'equivalent' by <=>
unit1 + unit2 >> "ft"             # converts result of math to 'ft'
(unit1 + unit2).convert_to('ft')  # converts result to 'ft'
```

Any object that defines a `to_unit` method will be automatically coerced to a
unit during calculations.

### Text Output

Units will display themselves nicely based on the display_name for the units and
prefixes. Since `Unit` implements a `Unit#to_s`, all that is needed in most
cases is:

```ruby
"#{Unit.new('1 mm')}"  #=> "1 mm"
```

The `to_s` also accepts some options.

```ruby
Unit.new('1.5 mm').to_s("%0.2f")  # "1.50 mm".  Enter any valid format
                                  #   string.  Also accepts strftime format
Unit.new('10 mm').to_s("%0.2f in")# "0.39 in". can also format and convert in
                                  # the same time.
Unit.new('1.5 mm').to_s("in")     # converts to inches before printing
Unit.new("2 m").to_s(:ft)         # returns 6'7"
Unit.new("100 kg").to_s(:lbs)     # returns 220 lbs, 7 oz
Unit.new("100 kg").to_s(:stone)   # returns 15 stone, 10 lb
```

### Time Helpers

Ruby-units extends the `Time`, `Date`, and `DateTime` classes to support unit-based arithmetic,
allowing you to add or subtract durations from time objects naturally.

#### Adding and Subtracting Durations

```ruby
Time.now + Unit.new("10 min")   #=> 10 minutes from now
Time.now - Unit.new("2 hours")  #=> 2 hours ago

Date.today + Unit.new("1 week")  #=> 7 days from today
Date.today - Unit.new("30 days") #=> 30 days ago
```

**Important:** When adding or subtracting large time units (years, decades, centuries),
the duration is first converted to days and rounded to maintain calendar accuracy.
This means `1 year` is treated as approximately 365 days rather than an exact number of seconds.

```ruby
Time.now + Unit.new("1 year")    #=> Approximately 365 days from now
Time.now - Unit.new("1 decade")  #=> Approximately 3650 days ago
```

For more precise durations, use smaller units (hours, minutes, seconds):

```ruby
Time.now + Unit.new("24 hours")  #=> Exactly 24 hours from now
```

#### Converting Time and Date to Units

You can convert `Time` objects to units representing the duration since the Unix epoch:

```ruby
Time.now.to_unit              #=> Duration in seconds since epoch
Time.now.to_unit('hours')     #=> Duration in hours since epoch
Time.now.to_unit('days')      #=> Duration in days since epoch
```

You can convert `Date` objects to units representing days since the Julian calendar start:

```ruby
Date.today.to_unit            #=> Duration in days since Julian calendar start
Date.today.to_unit('week')    #=> Duration in weeks since Julian calendar start
Date.today.to_unit('year')    #=> Duration in years since Julian calendar start
```

#### Creating Time from Units

Use `Time.at` to create a Time object from a duration unit:

```ruby
Time.at(Unit.new("1000 seconds"))           #=> Time 1000 seconds after epoch
Time.at(Unit.new("1 hour"), 500, :ms)       #=> Time 1 hour + 500 milliseconds after epoch
```

#### Convenience Methods

The `Time.in` method provides a shorthand for calculating future times:

```ruby
Time.in('5 min')    #=> 5 minutes from now
Time.in('2 hours')  #=> 2 hours from now
```

#### Duration Formats

Durations may be entered as 'HH:MM:SS, usec' and will be returned in 'hours'.

```ruby
Unit.new('1:00')     #=> 1 h
Unit.new('0:30')     #=> 0.5 h
Unit.new('0:30:30')  #=> 0.5 h + 30 sec
```

If only one ":" is present, it is interpreted as the separator between hours and
minutes.

#### Compatibility with Chronic

Several helpers are available for working with natural language time parsing.
Note: If you include the 'Chronic' gem, you can specify times in natural language.

```ruby
Unit.new('min').since(DateTime.parse('9/18/06 3:00pm'))
```

#### Range Errors and DateTime Fallback

If time arithmetic would result in a date outside the valid range for the `Time` class
(typically 1970-2038 on 32-bit systems), ruby-units automatically falls back to using
`DateTime` objects to handle the calculation.

### Ranges

```ruby
[Unit.new('0 h')..Unit.new('10 h')].each {|x| p x}
```

works so long as the starting point has an integer scalar

### Math Functions

Ruby-units extends the `Math` module to support Unit objects seamlessly. All trigonometric
and mathematical functions work with units, handling conversions automatically.

#### Supported Functions

**Trigonometric Functions** (angles converted to radians automatically):
- `sin`, `cos`, `tan` - Standard trigonometric functions
- `sinh`, `cosh`, `tanh` - Hyperbolic trigonometric functions

**Inverse Trigonometric Functions** (return angles in radians as Unit objects):
- `asin`, `acos`, `atan` - Inverse trigonometric functions
- `atan2` - Two-argument arctangent for full quadrant determination

**Root Functions** (preserve dimensional analysis):
- `sqrt` - Square root (e.g., √(4 m²) = 2 m)
- `cbrt` - Cube root (e.g., ³√(27 m³) = 3 m)

**Other Functions**:
- `hypot` - Euclidean distance calculation with units
- `log`, `log10` - Logarithmic functions (extract scalar from units)

#### Examples

```ruby
# Trigonometric functions with angle units
Math.sin(Unit.new("90 deg"))        #=> 1.0
Math.cos(Unit.new("180 deg"))       #=> -1.0
Math.tan(Unit.new("45 deg"))        #=> 1.0

# Works with different angle units
Math.sin(Unit.new("1.571 rad"))     #=> 1.0 (approximately π/2)
Math.cos(Unit.new("3.14159 rad"))   #=> -1.0 (approximately π)

# Inverse functions return Unit objects in radians
Math.asin(0.5)                       #=> Unit.new("0.524 rad") (30°)
Math.atan(1)                         #=> Unit.new("0.785 rad") (45°)
Math.acos(0)                         #=> Unit.new("1.571 rad") (90°)

# Root functions preserve dimensional analysis
Math.sqrt(Unit.new("4 m^2"))        #=> Unit.new("2 m")
Math.cbrt(Unit.new("27 m^3"))       #=> Unit.new("3 m")
Math.sqrt(Unit.new("9 kg*m/s^2"))   #=> Unit.new("3 kg^(1/2)*m^(1/2)/s")

# Hypot for distance calculations (Pythagorean theorem)
Math.hypot(Unit.new("3 m"), Unit.new("4 m"))     #=> Unit.new("5 m")
Math.hypot(Unit.new("30 cm"), Unit.new("40 cm")) #=> Unit.new("50 cm")

# atan2 for converting Cartesian to polar coordinates
Math.atan2(Unit.new("1 m"), Unit.new("1 m"))     #=> Unit.new("0.785 rad") (45°)
Math.atan2(Unit.new("1 m"), Unit.new("0 m"))     #=> Unit.new("1.571 rad") (90°)

# Logarithmic functions (units must be compatible for input)
Math.log10(Unit.new("100"))         #=> 2.0
Math.log(Unit.new("2.718"))         #=> 1.0 (natural log, approximately)
Math.log(Unit.new("8"), 2)          #=> 3.0 (log base 2)
```

**Note:** Trigonometric functions expect angular units or dimensionless numbers. If you pass
a Unit with dimensions (like meters), it will be converted to radians, which may produce
unexpected results.

### Temperatures

Ruby-units makes a distinction between a temperature (which technically is a
property) and degrees of temperature (which temperatures are measured in).

Temperature units (i.e., 'tempK') can be converted back and forth, and will take
into account the differences in the zero points of the various scales.
Differential temperature (e.g., Unit.new('100 degC')) units behave like most
other units.

```ruby
Unit.new('37 tempC').convert_to('tempF')   #=> 98.6 tempF
```

Ruby-units will raise an exception if you attempt to create a temperature unit
that would fall below absolute zero.

Unit math on temperatures is fairly limited.

```ruby
Unit.new('100 tempC') + Unit.new('10 degC')   # '110 tempC'.to_unit
Unit.new('100 tempC') - Unit.new('10 degC')   # '90 tempC'.to_unit
Unit.new('100 tempC') + Unit.new('50 tempC')  # exception (can't add two temperatures)
Unit.new('100 tempC') - Unit.new('50 tempC')  # '50 degC'.to_unit (get the difference between two temperatures)
Unit.new('50 tempC')  - Unit.new('100 tempC') # '-50 degC'.to_unit
Unit.new('100 tempC') * scalar                # '100*scalar tempC'.to_unit
Unit.new('100 tempC') / scalar                # '100/scalar tempC'.to_unit
Unit.new('100 tempC') * unit                  # exception
Unit.new('100 tempC') / unit                  # exception
Unit.new('100 tempC') ** N                    # exception

Unit.new('100 tempC').convert_to('degC')  #=> Unit.new('100 degC')
```

This conversion references the 0 point on the scale of the temperature unit

```ruby
Unit.new('100 degC').convert_to('tempC')  #=> '-173 tempC'.to_unit
```

These conversions are always interpreted as being relative to absolute zero.
Conversions are probably better done like this...

```ruby
Unit.new('0 tempC') + Unit.new('100 degC') #=> Unit.new('100 tempC')
```

### Defining Units

It is possible to define new units or redefine existing ones.

#### Define New Unit

The easiest approach is to define a unit in terms of other units using the block form.

```ruby
Unit.define("foobar") do |foobar|
  foobar.definition   = Unit.new("1 foo") * Unit.new("1 bar")   # anything that results in a Unit object
  foobar.aliases      = %w{foobar fb}                            # array of synonyms for the unit
  foobar.display_name = "Foobar"                                 # How unit is displayed when output
end
```

You can also create a unit definition directly and pass it to `Unit.define`:

```ruby
unit_definition = Unit::Definition.new("foobar") do |foobar|
  foobar.definition = Unit.new("1 baz")
  foobar.aliases = %w{foobar fb}
  foobar.display_name = "Foobar"
end
Unit.define(unit_definition)
```

For more control, you can set the unit attributes explicitly:

```ruby
Unit.define("electron-volt") do |ev|
  ev.aliases      = %w{eV electron-volt electron_volt}
  ev.scalar       = 1.602e-19
  ev.kind         = :energy
  ev.numerator    = %w{<kilogram> <meter> <meter>}
  ev.denominator  = %w{<second> <second>}
  ev.display_name = "electron-volt"
end
```

#### Redefine Existing Unit

Redefining a unit allows the user to change a single aspect of a definition
without having to re-create the entire definition. This is useful for changing
display names, adding aliases, etc.

```ruby
Unit.redefine!("cup") do |cup|
  cup.display_name  = "cup"
end
```

### Useful methods

1. `scalar` will return the numeric portion of the unit without the attached
   units
2. `base_scalar` will return the scalar in base units (SI)
3. `units` will return the name of the units (without the scalar)
4. `base` will return the unit converted to base units (SI)
5. `best_prefix` will return a new unit scaled with an appropriate prefix for
   human readability (e.g., '1000 m' becomes '1 km')

### Storing in a database

Units can be stored in a database as either the string representation or in two
separate columns defining the scalar and the units. Note that if sorting by
units is desired you will want to ensure that you are storing the scalars in a
consistent unit (i.e, the base units).

### Namespaced Class

Sometimes the default class 'Unit' may conflict with other gems or applications.
Internally ruby-units defines itself using the RubyUnits namespace. The actual
class of a unit is the RubyUnits::Unit. For simplicity and backwards
compatibility, the `::Unit` class is defined as an alias to `::RubyUnits::Unit`.

To load ruby-units without this alias...

```ruby
require 'ruby_units/namespaced'
```

When using bundler...

```ruby
gem 'ruby-units', require: 'ruby_units/namespaced'
```

Note: when using the namespaced version, the `Unit.new('unit string')` helper
will not be defined.

### Configuration

Configuration options can be set like:

```ruby
RubyUnits.configure do |config|
  config.format = :rational
  config.separator = :none
  config.default_precision = 0.001
end
```

#### Configuration Options

| Option              | Description                                                                                                            | Valid Values                | Default     |
|---------------------|------------------------------------------------------------------------------------------------------------------------|-----------------------------|-------------|
| `format`            | Only used for output formatting. `:rational` is formatted like `3 m/s^2`. `:exponential` is formatted like `3 m*s^-2`. | `:rational`, `:exponential` | `:rational` |
| `separator`         | Use a space separator for output. `:space` is formatted like `3 m/s`, `:none` is like `3m/s`.                          | `:space`, `:none`           | `:space`    |
| `default_precision` | The precision used when rationalizing fractional values in unit output.                                                | Any positive number         | `0.0001`    |

#### Examples

```ruby
# Change output format to exponential notation
RubyUnits.configure do |config|
  config.format = :exponential
end
# => "1 m*s^-2"

# Remove spaces between numbers and units
RubyUnits.configure do |config|
  config.separator = :none
end
# => "1m/s"

# Adjust precision for rational number conversion
RubyUnits.configure do |config|
  config.default_precision = 0.001
end

# Reset to defaults
RubyUnits.reset
```

**Note:** Boolean values (`true`/`false`) for `separator` are deprecated but still supported for backward compatibility. Use `:space` instead of `true` and `:none` instead of `false`.

### NOTES

#### Performance vs. Accuracy

Ruby units was originally intended to provide a robust and accurate way to do
arbitrary unit conversions. In some cases, these conversions can result in the
creation and garbage collection of a lot of intermediate objects during
calculations. This in turn can have a negative impact on performance. The design
of ruby-units has emphasized accuracy over speed. YMMV if you are doing a lot of
math involving units.

## Support Policy

Only currently maintained versions of ruby and jruby are supported.

## License

[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2Folbrich%2Fruby-units.svg?type=large)](https://app.fossa.io/projects/git%2Bgithub.com%2Folbrich%2Fruby-units?ref=badge_large)
