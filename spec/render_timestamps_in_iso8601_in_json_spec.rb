require "spec_helper"

describe ActiveSupport::TimeWithZone do
  describe "#as_json" do
    it "renders as iso8601 in UTC" do
      timestamp = Time.utc(2010, 3, 30, 5, 43, 25.123).in_time_zone("Eastern Time (US & Canada)")

      aggregate_failures do
        expect(timestamp).to be_a ActiveSupport::TimeWithZone
        expect(timestamp.as_json).to eq("2010-03-30T05:43:25.123Z")
        expect(timestamp.to_json).to eq('"2010-03-30T05:43:25.123Z"')
      end
    end
  end
end
