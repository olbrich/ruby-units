RubyUnits::UnitSystem.registered[:si].extend do
  {
    googol: [%w(googol), 10**100],
    yobi: [%w(Yi Yobi yobi), 2**80],
    zebi: [%w(Zi Zebi zebi), 2**70],
    exbi: [%w(Ei Exbi exbi), 2**60],
    pebi: [%w(Pi Pebi pebi), 2**50],
    tebi: [%w(Ti Tebi tebi), 2**40],
    gibi: [%w(Gi Gibi gibi), 2**30],
    mebi: [%w(Mi Mebi mebi), 2**20],
    kibi: [%w(Ki Kibi kibi), 2**10],
    yotta: [%w(Y Yotta yotta), 10**24],
    zetta: [%w(Z Zetta zetta), 10**21],
    exa: [%w(E Exa exa), 10**18],
    peta: [%w(P Peta peta), 10**15],
    tera: [%w(T Tera tera), 10**12],
    giga: [%w(G Giga giga), 10**9],
    mega: [%w(M Mega mega), 10**6],
    kilo: [%w(k kilo), 10**3],
    hecto: [%w(h Hecto hecto), 10**2],
    deca: [%w(da Deca deca deka), 10**1],
    deci: [%w(d Deci deci), Rational(1, 10**1)],
    centi: [%w(c Centi centi), Rational(1, 10**2)],
    milli: [%w(m Milli milli), Rational(1, 10**3)],
    micro: [%w(u µ Micro micro mc), Rational(1, 10**6)],
    nano: [%w(n Nano nano), Rational(1, 10**9)],
    pico: [%w(p Pico pico), Rational(1, 10**12)],
    femto: [%w(f Femto femto), Rational(1, 10**15)],
    atto: [%w(a Atto atto), Rational(1, 10**18)],
    zepto: [%w(z Zepto zepto), Rational(1, 10**21)],
    yocto: [%w(y Yocto yocto), Rational(1, 10**24)]
  }.each do |name, definition|
    prefix(name) do
      scalar definition.last
      aliases definition.first
    end
  end
end
