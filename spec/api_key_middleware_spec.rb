require 'rails_helper'
require 'securerandom'

RSpec.describe "/api/hellos", type: :request do
  let(:uuid) { api_client.key }
  let(:auth_header) { "MyAwesomeInternalScheme key=#{uuid}" }
  let(:allowlist) { nil }

  before do
    Stitches.configuration.reset_to_defaults!
    Stitches.configuration.custom_http_auth_scheme = 'MyAwesomeInternalScheme'
    Stitches.configuration.allowlist_regexp = allowlist if allowlist
    Stitches::ApiClientAccessWrapper.clear_api_cache
  end

  def execute_call(auth: auth_header)
    headers = {
      "Accept" => "application/json; version=1"
    }
    headers["Authorization"] = auth if auth

    get "/api/hellos", headers: headers
  end

  def expect_unauthorized
    expect(response.body).to include "Unauthorized"
    expect(response.status).to eq 401
    expect(response.headers["WWW-Authenticate"]).to eq("MyAwesomeInternalScheme realm=FakeApp")
  end

  context "with modern schema" do
    let(:api_client_enabled) { true }
    let!(:api_client) {
      uuid = SecureRandom.uuid
      ApiClient.create(name: "MyApiClient", key: SecureRandom.uuid, enabled: false, created_at: Time.now())
      ApiClient.create(name: "MyApiClient", key: uuid, enabled: api_client_enabled, created_at: Time.now())
    }

    context "when path is not on allowlist" do
      context "when api_client is valid" do
        it "executes the correct controller" do
          execute_call

          expect(response.body).to include "Hello"
        end

        it "saves the api_client information used" do
          execute_call

          expect(response.body).to include "MyApiClient"
          expect(response.body).to include "#{api_client.id}"
        end

        context "caching is enabled" do
          before do
            allow(ApiClient).to receive(:find_by).and_call_original

            Stitches.configure do |config|
              config.max_cache_ttl  = 5
              config.max_cache_size = 10
            end
          end

          it "only gets the the api_client information once" do
            execute_call
            execute_call

            expect(response.body).to include "#{api_client.id}"
            expect(ApiClient).to have_received(:find_by).once
          end
        end
      end

      context "when api client key does not match" do
        let(:uuid) { SecureRandom.uuid } # random uuid

        it "rejects request" do
          execute_call

          expect_unauthorized
        end
      end

      context "when api client key not enabled" do
        let(:api_client_enabled) { false }

        it "rejects request" do
          execute_call

          expect_unauthorized
        end
      end

      context "when authorization header is missing" do
        it "rejects request" do
          execute_call(auth: nil)

          expect_unauthorized
        end
      end

      context "when scheme does not match" do
        it "rejects request" do
          execute_call(auth: "OtherScheme key=#{uuid}")

          expect_unauthorized
        end
      end
    end

    context "when path is on allowlist" do
      let(:allowlist) { /.*hello.*/ }

      context "when api_client is valid" do
        it "executes the correct controller" do
          execute_call

          expect(response.body).to include "Hello"
        end

        it "does not save the api_client information used" do
          execute_call

          expect(response.body).to include "NameNotFound"
          expect(response.body).to include "IdNotFound"
        end
      end

      context "when api client key does not match" do
        let(:uuid) { SecureRandom.uuid } # random uuid

        it "executes the correct controller" do
          execute_call

          expect(response.body).to include "Hello"
        end
      end
    end
  end

  context "when schema is old and missing enabled field" do
    around(:each) do |example|
      load 'fake_app/db/schema_missing_enabled.rb'
      ApiClient.reset_column_information
      example.run
      load 'fake_app/db/schema_modern.rb'
      ApiClient.reset_column_information
    end

    let!(:api_client) {
      uuid = SecureRandom.uuid
      ApiClient.create(name: "MyApiClient", key: uuid, created_at: Time.now())
    }

    context "when api_client is valid" do
      it "executes the correct controller" do
        execute_call

        expect(response.body).to include "Hello"
      end

      it "saves the api_client information used" do
        execute_call

        expect(response.body).to include "MyApiClient"
        expect(response.body).to include "#{api_client.id}"
      end
    end
  end
end
