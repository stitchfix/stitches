require 'rails_helper'

describe Stitches::CallingServiceName do
  let(:headers) { {} }
  let(:fake_request) { double("request", headers: headers) }
  let(:fake_controller) {
    req = fake_request
    Object.new.tap { |c|
      c.extend(described_class)
      c.define_singleton_method(:request) { req }
    }
  }

  describe "#calling_service_name" do
    context "when the header is present" do
      let(:headers) { {"X-StitchFix-Calling-Service" => "kingmob"} }

      it "returns the header value" do
        expect(fake_controller.calling_service_name).to eq("kingmob")
      end
    end

    context "when the header is absent" do
      it "returns empty string" do
        expect(fake_controller.calling_service_name).to eq("")
      end
    end

    context "when the header is blank" do
      let(:headers) { {"X-StitchFix-Calling-Service" => ""} }

      it "returns empty string" do
        expect(fake_controller.calling_service_name).to eq("")
      end
    end
  end

  describe "configurable header" do
    it "defaults to X-StitchFix-Calling-Service" do
      expect(Stitches.configuration.calling_service_header).to eq("X-StitchFix-Calling-Service")
    end

    context "when configured to a custom header" do
      let(:headers) { {"X-Custom-Caller" => "my-service"} }

      before { Stitches.configuration.calling_service_header = "X-Custom-Caller" }
      after { Stitches.configuration.reset_to_defaults! }

      it "reads from the configured header" do
        expect(fake_controller.calling_service_name).to eq("my-service")
      end
    end
  end
end
