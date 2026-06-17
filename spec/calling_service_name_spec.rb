require 'rails_helper'

describe Stitches::CallingServiceName do
  let(:headers) { {} }
  let(:env) { {} }
  let(:fake_request) { double("request", headers: headers, env: env) }
  let(:fake_controller) {
    req = fake_request
    Object.new.tap { |c|
      c.extend(described_class)
      c.define_singleton_method(:request) { req }
    }
  }

  describe "#calling_service_name" do
    context "when X-StitchFix-Calling-Service header is present" do
      let(:headers) { {"X-StitchFix-Calling-Service" => "kingmob"} }

      it "returns the header value" do
        expect(fake_controller.calling_service_name).to eq("kingmob")
      end

      context "and env var client is also present" do
        let(:env) { {Stitches.configuration.env_var_to_hold_api_client => double(name: "other-service")} }

        it "prefers the header" do
          expect(fake_controller.calling_service_name).to eq("kingmob")
        end
      end
    end

    context "when header is absent but env var client is present" do
      let(:env) { {Stitches.configuration.env_var_to_hold_api_client => double(name: "mobile-service")} }

      it "returns the client name from env" do
        expect(fake_controller.calling_service_name).to eq("mobile-service")
      end
    end

    context "when header is blank" do
      let(:headers) { {"X-StitchFix-Calling-Service" => ""} }
      let(:env) { {Stitches.configuration.env_var_to_hold_api_client => double(name: "fallback-service")} }

      it "treats blank as absent and falls through to env var client" do
        expect(fake_controller.calling_service_name).to eq("fallback-service")
      end
    end

    context "when neither header nor env var client is present" do
      it "returns empty string" do
        expect(fake_controller.calling_service_name).to eq("")
      end
    end

    context "when env var client is nil" do
      let(:env) { {Stitches.configuration.env_var_to_hold_api_client => nil} }

      it "returns empty string" do
        expect(fake_controller.calling_service_name).to eq("")
      end
    end

  end

  describe "::HEADER" do
    it "is the expected header name" do
      expect(described_class::HEADER).to eq("X-StitchFix-Calling-Service")
    end
  end
end
