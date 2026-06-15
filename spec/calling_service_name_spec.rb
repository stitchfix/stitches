require 'rails_helper'

describe Stitches::CallingServiceName do
  let(:headers) { {} }
  let(:request) { double("request", headers: headers) }
  let(:api_client) { nil }
  let(:fake_controller) {
    Object.new.tap { |c|
      c.extend(described_class)
      c.define_singleton_method(:request) { request }
      c.define_singleton_method(:api_client) { api_client }
    }
  }

  describe "#calling_service_name" do
    context "when X-StitchFix-Calling-Service header is present" do
      let(:headers) { {"X-StitchFix-Calling-Service" => "kingmob"} }

      it "returns the header value" do
        expect(fake_controller.calling_service_name).to eq("kingmob")
      end

      context "and api_client is also present" do
        let(:api_client) { double("ApiClient", name: "other-service") }

        it "prefers the header" do
          expect(fake_controller.calling_service_name).to eq("kingmob")
        end
      end
    end

    context "when header is absent but api_client is present" do
      let(:api_client) { double("ApiClient", name: "mobile-service") }

      it "returns the api_client name" do
        expect(fake_controller.calling_service_name).to eq("mobile-service")
      end
    end

    context "when header is blank" do
      let(:headers) { {"X-StitchFix-Calling-Service" => ""} }
      let(:api_client) { double("ApiClient", name: "fallback-service") }

      it "treats blank as absent and falls through to api_client" do
        expect(fake_controller.calling_service_name).to eq("fallback-service")
      end
    end

    context "when neither header nor api_client is present" do
      it "returns 'unknown'" do
        expect(fake_controller.calling_service_name).to eq("unknown")
      end
    end

    context "when api_client is nil" do
      let(:api_client) { nil }

      it "returns 'unknown'" do
        expect(fake_controller.calling_service_name).to eq("unknown")
      end
    end
  end

  describe "::HEADER" do
    it "is the expected header name" do
      expect(described_class::HEADER).to eq("X-StitchFix-Calling-Service")
    end
  end
end
