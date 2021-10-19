require 'rails_helper'
require 'securerandom'

RSpec.describe "/api/hellos", type: :request do
  let(:version) { 8  }
  let(:accept_header) { "application/json; version=#{version}" }
  let(:headers) {
    h = {}
    h["Accept"] = accept_header if accept_header
    h
  }

  before do
    Stitches.configuration.reset_to_defaults!
    Stitches.configuration.allowlist_regexp = /.*hello.*/
    Stitches::ApiClientAccessWrapper.clear_api_cache
  end

  context "when correctly configured for version 1" do
    let(:version) { 1 }

    it "executes the correct controller" do
      get "/api/hellos", headers: headers

      expect(response.body).to include "Hello"
    end
  end

  context "when correctly configured for version 2" do
    let(:version) { 2 }

    it "executes the correct controller" do
      get "/api/hellos", headers: headers

      expect(response.body).to include "Greetings"
    end
  end

  context "when correctly configured for a version that does not exist" do
    let(:version) { 6 }

    it "fails to map to a controller" do
      expect {
        get "/api/hellos", headers: headers
      }.to raise_error(ActionController::RoutingError)
    end
  end

  context "when accept header is missing version" do
    let(:accept_header) { "application/json" }

    it "fails to map to a controller" do
      expect {
        get "/api/hellos", headers: headers
      }.to raise_error(ActionController::RoutingError)
    end
  end
end
