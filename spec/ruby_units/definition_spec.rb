RSpec.describe RubyUnits::Unit::Definition do
  describe 'eV' do
    subject(:ev) do
      described_class.new('eV') do |ev|
        ev.aliases = %w[eV electron-volt]
        ev.definition = RubyUnits::Unit.new('1.602E-19 joule')
        ev.display_name = 'electron-volt'
      end
    end

    it do
      expect(ev).to have_attributes(
        aliases: %w[eV electron-volt],
        base?: false,
        denominator: %w[<second> <second>],
        display_name: 'electron-volt',
        name: '<eV>',
        numerator: %w[<kilogram> <meter> <meter>],
        prefix?: false,
        scalar: 1.602E-19,
        temperature_scale: nil,
        temperature?: false,
        unity?: false
      )
    end
  end

  describe 'tempK' do
    subject(:tempK) do
      RubyUnits::Unit.definition('tempK')
    end

    it do
      expect(tempK).to have_attributes(
        aliases: %w[tempK],
        base?: true,
        denominator: %w[<1>],
        display_name: 'tempK',
        name: '<tempK>',
        numerator: %w[<tempK>],
        prefix?: false,
        scalar: 1,
        temperature_scale: 'degK',
        temperature?: true,
        unity?: false
      )
    end
  end

  describe 'kelvin' do
    subject(:kelvin) do
      RubyUnits::Unit.definition('kelvin')
    end

    it do
      expect(kelvin).to have_attributes(
        aliases: %w[degK kelvin],
        base?: true,
        denominator: %w[<1>],
        display_name: 'degK',
        name: '<kelvin>',
        numerator: %w[<kelvin>],
        prefix?: false,
        scalar: 1,
        temperature_scale: nil,
        temperature?: true,
        unity?: false
      )
    end
  end
end
