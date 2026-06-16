require 'rails_helper'

describe Stitches::CallingServiceName do
  let(:headers) { {} }
  let(:fake_request) { double("request", headers: headers) }
  let(:fake_api_client) { nil }
  let(:fake_controller) {
    req = fake_request
    client = fake_api_client
    Object.new.tap { |c|
      c.extend(described_class)
      c.define_singleton_method(:request) { req }
      c.define_singleton_method(:api_client) { client }
    }
  }

  describe "#calling_service_name" do
    context "when X-StitchFix-Calling-Service header is present" do
      let(:headers) { {"X-StitchFix-Calling-Service" => "kingmob"} }

      it "returns the header value" do
        expect(fake_controller.calling_service_name).to eq("kingmob")
      end

      context "and api_client is also present" do
        let(:fake_api_client) { double("ApiClient", name: "other-service") }

        it "prefers the header" do
          expect(fake_controller.calling_service_name).to eq("kingmob")
        end
      end
    end

    context "when header is absent but api_client is present" do
      let(:fake_api_client) { double("ApiClient", name: "mobile-service") }

      it "returns the api_client name" do
        expect(fake_controller.calling_service_name).to eq("mobile-service")
      end
    end

    context "when header is blank" do
      let(:headers) { {"X-StitchFix-Calling-Service" => ""} }
      let(:fake_api_client) { double("ApiClient", name: "fallback-service") }

      it "treats blank as absent and falls through to api_client" do
        expect(fake_controller.calling_service_name).to eq("fallback-service")
      end
    end

    context "when neither header nor api_client is present" do
      it "returns 'unknown'" do
        expect(fake_controller.calling_service_name).to eq("N/A")
      end
    end

    context "when api_client is nil" do
      let(:fake_api_client) { nil }

      it "returns 'N/A'" do
        expect(fake_controller.calling_service_name).to eq("N/A")
      end
    end

    context "when api_client method is not defined" do
      let(:fake_controller) {
        req = fake_request
        Object.new.tap { |c|
          c.extend(described_class)
          c.define_singleton_method(:request) { req }
        }
      }

      it "returns 'N/A'" do
        expect(fake_controller.calling_service_name).to eq("N/A")
      end

      context "and header is present" do
        let(:headers) { {"X-StitchFix-Calling-Service" => "fixops"} }

        it "returns the header value" do
          expect(fake_controller.calling_service_name).to eq("fixops")
        end
      end
    end
  end

  describe "::HEADER" do
    it "is the expected header name" do
      expect(described_class::HEADER).to eq("X-StitchFix-Calling-Service")
    end
  end
end
