require File.dirname(__FILE__) + '/../spec_helper'

describe Time do
  let(:now) { Time.at(1_303_656_390) }
  before(:each) do
    allow(Time).to receive(:now).and_return(now)
  end

  context '.at' do
    subject { Date.new(2011, 4, 1).to_unit }
    specify { expect(Time.at(Time.at(0)).utc.strftime('%D %T')).to eq('01/01/70 00:00:00') }
    specify { expect(Time.at(subject - Date.new(1970, 1, 1)).getutc.strftime('%D %T')).to eq('04/01/11 00:00:00') }
    specify { expect(Time.at(subject - Date.new(1970, 1, 1), 500).usec).to eq(500) }
  end

  context '.in' do
    specify { expect(Time.in('5 min')).to be_a Time }
    specify { expect(Time.in('5 min')).to be > Time.now }
  end

  context '#to_date' do
    subject { Time.parse('2012-01-31 11:59:59') }
    specify { expect(subject.to_date.to_s).to eq('2012-01-31') }
    specify { expect((subject + 1).to_date.to_s).to eq('2012-01-31') }
  end

  context '#to_unit' do
    subject { now }

    describe '#to_unit' do
      subject { super().to_unit }
      it { is_expected.to be_an_instance_of(Unit) }
    end

    describe '#to_unit' do
      subject { super().to_unit }
      describe '#units' do
        subject { super().units }
        it { is_expected.to eq('s') }
      end
    end
    specify               { expect(subject.to_unit('h').kind).to eq(:time) }
    specify               { expect(subject.to_unit('h').units).to eq('h') }
  end

  context 'addition (+)' do
    specify { expect(Time.now + 1).to eq(Time.at(1_303_656_390 + 1)) }
    specify { expect(Time.now + RubyUnits::Unit.new('10 min')).to eq(Time.at(1_303_656_390 + 600)) }
  end

  context 'subtraction (-)' do
    specify { expect(Time.now - 1).to eq(Time.at(1_303_656_390 - 1)) }
    specify { expect(Time.now - RubyUnits::Unit.new('10 min')).to eq(Time.at(1_303_656_390 - 600)) }
    specify { expect(Time.now - RubyUnits::Unit.new('150 years')).to eq(Time.parse('1861-04-24 09:46:30 -0500')) }
  end
end
