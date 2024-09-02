# frozen_string_literal: true

RSpec.describe RubyUnits::Date do
  subject(:date_unit) { date.to_unit }

  let(:date) { Date.new(2011, 4, 1) }

  it { is_expected.to be_a Unit }
  it { is_expected.to respond_to :to_unit }
  it { is_expected.to respond_to :to_time }
  it { is_expected.to respond_to :to_date }
  it { is_expected.to have_attributes(scalar: date.ajd, units: 'd', kind: :time) }

  describe 'offsets' do
    specify { expect(date + '5 days'.to_unit).to eq(Date.new(2011, 4, 6)) }
    specify { expect(date - '5 days'.to_unit).to eq(Date.new(2011, 3, 27)) }
    # 2012 is a leap year...
    specify { expect(date + '1 year'.to_unit).to eq(Date.new(2012, 3, 31)) }
    specify { expect(date - '1 year'.to_unit).to eq(Date.new(2010, 4, 1)) }
    # adding Time or Date objects to a Duration don't make any sense, so raise
    # an error.
    specify { expect { date_unit + Date.new(2011, 4, 1) }.to raise_error(ArgumentError, 'Date and Time objects represent fixed points in time and cannot be added to a Unit') }
    specify { expect { date_unit + DateTime.new(2011, 4, 1, 12, 0, 0) }.to raise_error(ArgumentError, 'Date and Time objects represent fixed points in time and cannot be added to a Unit') }
    specify { expect { date_unit + Time.parse('2011-04-01 12:00:00') }.to raise_error(ArgumentError, 'Date and Time objects represent fixed points in time and cannot be added to a Unit') }

    specify { expect(date_unit - Date.new(2011, 4, 1)).to be_zero }
    specify { expect(date_unit - DateTime.new(2011, 4, 1, 0, 0, 0)).to be_zero }

    specify do
      expect { (date_unit - Time.parse('2011-04-01 00:00')) }.to raise_error(ArgumentError,
                                                                             'Date and Time objects represent fixed points in time and cannot be subtracted from a Unit')
    end

    specify { expect(Date.new(2011, 4, 1) + 1).to eq(Date.new(2011, 4, 2)) }
  end
end
