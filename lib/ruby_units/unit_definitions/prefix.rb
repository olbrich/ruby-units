{
  'googol' => [%w[googol],             1e100],
  'yobi'   => [%w[Yi Yobi yobi],       2**80],
  'zebi'   => [%w[Zi Zebi zebi],       2**70],
  'exbi'   => [%w[Ei Exbi exbi],       2**60],
  'pebi'   => [%w[Pi Pebi pebi],       2**50],
  'tebi'   => [%w[Ti Tebi tebi],       2**40],
  'gibi'   => [%w[Gi Gibi gibi],       2**30],
  'mebi'   => [%w[Mi Mebi mebi],       2**20],
  'kibi'   => [%w[Ki Kibi kibi],       2**10],
  'yotta'  => [%w[Y Yotta yotta],      1e24],
  'zetta'  => [%w[Z Zetta zetta],      1e21],
  'exa'    => [%w[E Exa exa],          1e18],
  'peta'   => [%w[P Peta peta],        1e15],
  'tera'   => [%w[T Tera tera],        1e12],
  'giga'   => [%w[G Giga giga],        1e9],
  'mega'   => [%w[M Mega mega],        1e6],
  'kilo'   => [%w[k kilo],             1e3],
  'hecto'  => [%w[h Hecto hecto],      1e2],
  'deca'   => [%w[da Deca deca deka],  1e1],
  '1'      => [%w[1],                  1],
  'deci'   => [%w[d Deci deci],        Rational(1, 1e1)],
  'centi'  => [%w[c Centi centi],      Rational(1, 1e2)],
  'milli'  => [%w[m Milli milli],      Rational(1, 1e3)],
  'micro'  => [%w[u µ Micro micro mc], Rational(1, 1e6)],
  'nano'   => [%w[n Nano nano],        Rational(1, 1e9)],
  'pico'   => [%w[p Pico pico],        Rational(1, 1e12)],
  'femto'  => [%w[f Femto femto],      Rational(1, 1e15)],
  'atto'   => [%w[a Atto atto],        Rational(1, 1e18)],
  'zepto'  => [%w[z Zepto zepto],      Rational(1, 1e21)],
  'yocto'  => [%w[y Yocto yocto],      Rational(1, 1e24)]
}.each do |name, definition|
  RubyUnits::Unit.define(name) do |unit|
    aliases, scalar = definition
    unit.aliases    = aliases
    unit.scalar     = scalar
    unit.kind       = :prefix
  end
end
