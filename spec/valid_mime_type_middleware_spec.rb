require 'rails_helper'
require 'securerandom'

RSpec.describe "/api/hellos", type: :request do
  let!(:api_client) {
    uuid = SecureRandom.uuid
    ApiClient.create(name: "MyApiClient", key: uuid, enabled: true, created_at: Time.now())
  }
  let(:uuid) { api_client.key }
  let(:auth_header) { "MyAwesomeInternalScheme key=#{uuid}" }
  let(:accept_header) { "application/json; version=1" }
  let(:headers) {
    h = {
      "Authorization" => auth_header
    }
    h["Accept"] = accept_header if accept_header
    h
  }
  let(:allowlist) { nil }

  before do
    Stitches.configuration.reset_to_defaults!
    Stitches.configuration.custom_http_auth_scheme = 'MyAwesomeInternalScheme'
    Stitches::ApiClientAccessWrapper.clear_api_cache
  end

  def execute_call(accept_header:)
    headers = {
      "Authorization" => auth_header
    }
    headers["Accept"] = accept_header if accept_header

    get "/api/hellos", headers: headers
  end

  it "returns good result when no problems exist in accept_header" do
    execute_call(accept_header: "application/json; version=1")

    expect(response.status).to eq 200
  end

  it "fails accept header has missing version" do
    execute_call(accept_header: "application/json")

    expect(response.status).to eq 406
  end

  it "fails accept header has bad version" do
    execute_call(accept_header: "application/json; version=nan")

    expect(response.status).to eq 406
  end

  it "fails when mime type is bad" do
    execute_call(accept_header: "application/xml; version=1")

    expect(response.status).to eq 406
  end
end
