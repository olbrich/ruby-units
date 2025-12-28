# frozen_string_literal: true

RSpec.describe RubyUnits::Time do
  let(:now) { Time.at(1_303_656_390, in: "-04:00") }

  before do
    allow(Time).to receive(:now).and_return(now)
  end

  # We need to make sure this works will all the variations of the way that ruby
  # allows `at` to be called.
  describe ".at" do
    subject(:date_unit) { Date.new(2011, 4, 1).to_unit - Date.new(1970, 1, 1) }

    specify { expect(Time.at(Time.at(0)).utc.strftime("%D %T")).to eq("01/01/70 00:00:00") }
    specify { expect(Time.at(date_unit).getutc.strftime("%D %T")).to eq("04/01/11 00:00:00") }

    specify { expect(Time.at(date_unit, 500).usec).to eq(500) } # at(seconds, microseconds_with_fraction)
    specify { expect(Time.at(date_unit, 5, :millisecond).usec).to eq(5000) } # at(seconds, milliseconds, :millisecond)
    specify { expect(Time.at(date_unit, 500, :usec).usec).to eq(500) } # at(seconds, microseconds, :usec)
    specify { expect(Time.at(date_unit, 500, :microsecond).usec).to eq(500) } # at(seconds, microseconds, :microsecond)
    specify { expect(Time.at(date_unit, 500, :nsec).nsec).to eq(500) } # at(seconds, nanoseconds, :nsec)
    specify { expect(Time.at(date_unit, 500, :nanosecond).nsec).to eq(500) } # at(seconds, nanoseconds, :nanosecond)
    specify { expect(Time.at(date_unit, in: "-05:00").utc_offset).to eq(-18_000) } # at(seconds, in: timezone)
    specify { expect(Time.at(date_unit, 500, in: "-05:00")).to have_attributes(usec: 500, utc_offset: -18_000) } # at(seconds, microseconds, in: timezone)
    specify { expect(Time.at(date_unit, 5, :millisecond, in: "-05:00")).to have_attributes(usec: 5000, utc_offset: -18_000) } # at(seconds, milliseconds, :millisecond, in: timezone)
    specify { expect(Time.at(date_unit, 500, :usec, in: "-05:00")).to have_attributes(usec: 500, utc_offset: -18_000) } # at(seconds, microseconds, :usec, in: timezone)
    specify { expect(Time.at(date_unit, 500, :microsecond, in: "-05:00")).to have_attributes(usec: 500, utc_offset: -18_000) } # at(seconds, microseconds, :microsecond, in: timezone)
    specify { expect(Time.at(date_unit, 500, :nsec, in: "-05:00")).to have_attributes(nsec: 500, utc_offset: -18_000) } # at(seconds, nanoseconds, :nsec, in: timezone)
    specify { expect(Time.at(date_unit, 500, :nanosecond, in: "-05:00")).to have_attributes(nsec: 500, utc_offset: -18_000) } # at(seconds, nanoseconds, :nanosecond, in: timezone)

    specify { expect(Time.at(now.to_i, 500).usec).to eq(500) } # at(seconds, microseconds_with_fraction)
    specify { expect(Time.at(now.to_i, 5, :millisecond).usec).to eq(5000) } # at(seconds, milliseconds, :millisecond)
    specify { expect(Time.at(now.to_i, 500, :usec).usec).to eq(500) } # at(seconds, microseconds, :usec)
    specify { expect(Time.at(now.to_i, 500, :microsecond).usec).to eq(500) } # at(seconds, microseconds, :microsecond)
    specify { expect(Time.at(now.to_i, 500, :nsec).nsec).to eq(500) } # at(seconds, nanoseconds, :nsec)
    specify { expect(Time.at(now.to_i, 500, :nanosecond).nsec).to eq(500) } # at(seconds, nanoseconds, :nanosecond)
    specify { expect(Time.at(now.to_i, in: "-05:00").utc_offset).to eq(-18_000) } # at(seconds, in: timezone)
    specify { expect(Time.at(now.to_i, 500, in: "-05:00")).to have_attributes(usec: 500, utc_offset: -18_000) } # at(seconds, microseconds, in: timezone)
    specify { expect(Time.at(now.to_i, 5, :millisecond, in: "-05:00")).to have_attributes(usec: 5000, utc_offset: -18_000) } # at(seconds, milliseconds, :millisecond, in: timezone)
    specify { expect(Time.at(now.to_i, 500, :usec, in: "-05:00")).to have_attributes(usec: 500, utc_offset: -18_000) } # at(seconds, microseconds, :usec, in: timezone)
    specify { expect(Time.at(now.to_i, 500, :microsecond, in: "-05:00")).to have_attributes(usec: 500, utc_offset: -18_000) } # at(seconds, microseconds, :microsecond, in: timezone)
    specify { expect(Time.at(now.to_i, 500, :nsec, in: "-05:00")).to have_attributes(nsec: 500, utc_offset: -18_000) } # at(seconds, nanoseconds, :nsec, in: timezone)
    specify { expect(Time.at(now.to_i, 500, :nanosecond, in: "-05:00")).to have_attributes(nsec: 500, utc_offset: -18_000) } # at(seconds, nanoseconds, :nanosecond, in: timezone)
  end

  describe ".in" do
    specify { expect(Time.in("5 min")).to have_attributes(to_s: "2011-04-24 10:51:30 -0400") }
    specify { expect(Time.in([5, "min"])).to have_attributes(to_s: "2011-04-24 10:51:30 -0400") }
    specify { expect { Time.in(300) }.to raise_error(ArgumentError, "Incompatible Units ('300' not compatible with '1 s')") }
  end

  describe "#to_unit" do
    subject { now.to_unit }

    it { is_expected.to have_attributes(units: "s", scalar: now.to_f, kind: :time) }

    context "when an argument is passed" do
      subject { now.to_unit("min") }

      it { is_expected.to have_attributes(units: "min", scalar: now.to_f / 60.0, kind: :time) }
    end
  end

  describe "addition (+)" do
    specify { expect(Time.now + 1).to eq(now + 1) }
    specify { expect(Time.now + RubyUnits::Unit.new("10 min")).to eq(now + 600) }
  end

  describe "subtraction (-)" do
    specify { expect(Time.now - 1).to eq(now - 1) }
    specify { expect(Time.now - RubyUnits::Unit.new("10 min")).to eq(now - 600) }
  end
end
