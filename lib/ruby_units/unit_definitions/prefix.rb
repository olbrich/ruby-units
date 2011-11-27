prefixes = {
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
  '<deci>'  =>  [%w{d Deci deci}, Rational(1,1e1), :prefix],
  '<centi>'  => [%w{c Centi centi}, Rational(1,1e2), :prefix],
  '<milli>' =>  [%w{m Milli milli}, Rational(1,1e3), :prefix],
  '<micro>'  => [%w{u Micro micro}, Rational(1,1e6), :prefix],
  '<nano>'  =>  [%w{n Nano nano}, Rational(1,1e9), :prefix],
  '<pico>'  =>  [%w{p Pico pico}, Rational(1,1e12), :prefix],
  '<femto>' =>  [%w{f Femto femto}, Rational(1,1e15), :prefix],
  '<atto>'  =>  [%w{a Atto atto}, Rational(1,1e18), :prefix],
  '<zepto>' =>  [%w{z Zepto zepto}, Rational(1,1e21), :prefix],
  '<yocto>' =>  [%w{y Yocto yocto}, Rational(1,1e24), :prefix],
  '<1>'     =>  [%w{1},1,:prefix]
}

prefixes.each do |prefix, definition|
  Unit.define(Unit::Definition.new(prefix, definition))
end