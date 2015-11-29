require_relative '../../lib/ruby_units/unit_system'
require_relative '../../lib/ruby_units/definition/base'
require_relative '../../lib/ruby_units/definition/prefix'
require_relative '../../lib/ruby_units/definition/derived'

describe RubyUnits::UnitSystem::Proxy::Base do
  subject { described_class.new('foobar') }

  methods = %i(
    kind
    display_name
    aliases
    attributes
  )
  methods.each do |meth|
    it { is_expected.to respond_to(meth) }
  end

  its(:attributes) { is_expected.to eq(name: 'foobar') }

  it 'stores values in the attributes array' do
    subject.kind :baz
    subject.display_name 'fb'
    subject.aliases %w(fb foobar)
    expect(subject.attributes[:kind]).to eq :baz
    expect(subject.attributes[:display_name]).to eq 'fb'
    expect(subject.attributes[:aliases]).to eq %w(fb foobar)
  end
end

describe RubyUnits::UnitSystem::Proxy::Prefix do
  subject { described_class.new('foobar') }

  methods = %i(
    scalar
    display_name
    aliases
    attributes
  )
  methods.each do |meth|
    it { is_expected.to respond_to(meth) }
  end

  its(:attributes) { is_expected.to eq(name: 'foobar') }

  it 'stores values in the attributes array' do
    subject.scalar 1
    subject.display_name 'fb'
    subject.aliases %w(fb foobar)
    expect(subject.attributes[:scalar]).to eq 1
    expect(subject.attributes[:display_name]).to eq 'fb'
    expect(subject.attributes[:aliases]).to eq %w(fb foobar)
  end
end

describe RubyUnits::UnitSystem::Proxy::Derived do
  subject { described_class.new('foobar') }

  methods = %i(
    definition
    scalar
    numerator
    denominator
    kind
    display_name
    aliases
    attributes
  )
  methods.each do |meth|
    it { is_expected.to respond_to(meth) }
  end

  its(:attributes) { is_expected.to eq(name: 'foobar') }

  it 'stores values in the attributes array' do
    subject.scalar 1
    subject.numerator [:foobar]
    subject.denominator [:second]
    subject.kind :baz
    subject.display_name 'fb'
    subject.aliases %w(fb foobar)
    expect(subject.attributes[:scalar]).to eq 1
    expect(subject.attributes[:numerator]).to eq [:foobar]
    expect(subject.attributes[:denominator]).to eq [:second]
    expect(subject.attributes[:kind]).to eq :baz
    expect(subject.attributes[:display_name]).to eq 'fb'
    expect(subject.attributes[:aliases]).to eq %w(fb foobar)
  end

  it 'requires a block to be passed for a definition' do
    expect { subject.definition '1 m' }.to raise_error(ArgumentError, 'Block required for definition')
  end
end

describe RubyUnits::UnitSystem do
  context 'class methods' do
    subject do
      RubyUnits::UnitSystem.new('Fake Unit System', :fake)
    end

    specify 'a unit system can be registered' do
      RubyUnits::UnitSystem.register(subject)
      expect(RubyUnits::UnitSystem.registered.keys).to include :fake
    end

    specify 'objects that are not unit systems cannot be registered' do
      expect { RubyUnits::UnitSystem.register('Random Object') }.to raise_error(ArgumentError)
    end
  end

  context 'a new system' do
    subject do
      RubyUnits::UnitSystem.new('Astronomical system of units', :astronomical) do
        base(:astronomical_unit) do
          kind :length
          aliases %w(AU)
        end

        base(:solar_mass) do
          kind :mass
          aliases %w(M⊙)
        end

        base(:day) do
          kind :time
          aliases %w(D)
        end

        prefix(:kilo) do
          scalar 1000
          aliases %w(k kilo)
        end

        # this one is made up
        derived(:astro_newton) do
          scalar 1
          definition { Unit.new(1, 'M⊙*AU/D^2') }
          aliases %w(AN)
        end
      end
    end

    its(:name) { is_expected.to eq 'Astronomical system of units' }
    its(:abbreviation) { is_expected.to eq :astronomical }
    its('base_units.keys') { are_expected.to eq [:astronomical_unit, :solar_mass, :day] }
    its('derived_units.keys') { are_expected.to eq [:astro_newton] }
    its('prefixes.keys') { are_expected.to eq [:kilo] }
  end
end
