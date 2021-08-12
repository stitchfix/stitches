require 'rails_helper'
require 'securerandom'

class FakeLogger
  # This shouldn't be needed but there's a weird mocking conflict with kernal warn method otherwise
  def warn(message)
  end
end

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
    let(:disabled_at) { nil }
    let!(:api_client) {
      uuid = SecureRandom.uuid
      ApiClient.create(name: "MyApiClient", key: SecureRandom.uuid, enabled: false, created_at: 20.days.ago, disabled_at: 15.days.ago)
      ApiClient.create(name: "MyApiClient", key: uuid, enabled: api_client_enabled, created_at: 10.days.ago, disabled_at: disabled_at)
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

        context "when disabled_at is not set" do
          it "rejects request" do
            execute_call

            expect_unauthorized
          end
        end

        context "when disabled_at is set to a time older than three days ago" do
          let(:disabled_at) { 4.day.ago }

          it "allows the call" do
            execute_call

            expect_unauthorized
          end
        end

        context "when disabled_at is set to a recent time" do
          let(:disabled_at) { 1.day.ago }

          it "allows the call" do
            execute_call

            expect(response.body).to include "Hello"
            expect(response.body).to include "MyApiClient"
            expect(response.body).to include "#{api_client.id}"
          end

          it "warns about the disabled key to log writer when available" do
            stub_const("StitchFix::Logger::LogWriter", FakeLogger.new)
            allow(StitchFix::Logger::LogWriter).to receive(:warn)

            execute_call

            expect(StitchFix::Logger::LogWriter).to have_received(:warn).once
          end

          it "warns about the disabled key to the Rails.logger" do
            allow(Rails.logger).to receive(:warn)
            allow(Rails.logger).to receive(:error)

            execute_call

            expect(Rails.logger).to have_received(:warn).once
            expect(Rails.logger).not_to have_received(:error)
          end
        end

        context "when disabled_at is set to a dangerously long time" do
          let(:disabled_at) { 52.hours.ago }

          it "allows the call" do
            execute_call

            expect(response.body).to include "Hello"
            expect(response.body).to include "MyApiClient"
            expect(response.body).to include "#{api_client.id}"
          end

          it "logs error about the disabled key to log writer when available" do
            stub_const("StitchFix::Logger::LogWriter", FakeLogger.new)
            allow(StitchFix::Logger::LogWriter).to receive(:error)

            execute_call

            expect(StitchFix::Logger::LogWriter).to have_received(:error).once
          end

          it "logs error about the disabled key to the Rails.logger" do
            allow(Rails.logger).to receive(:warn)
            allow(Rails.logger).to receive(:error)

            execute_call

            expect(Rails.logger).to have_received(:error).once
            expect(Rails.logger).not_to have_received(:warn)
          end
        end

        context "when disabled_at is set to an unacceptably long time" do
          let(:disabled_at) { 5.days.ago }

          it "forbids the call" do
            execute_call

            expect_unauthorized
          end

          it "logs error about the disabled key to log writer when available" do
            stub_const("StitchFix::Logger::LogWriter", FakeLogger.new)
            allow(StitchFix::Logger::LogWriter).to receive(:error)

            execute_call

            expect(StitchFix::Logger::LogWriter).to have_received(:error).once
          end

          it "logs error about the disabled key to the Rails.logger" do
            allow(Rails.logger).to receive(:warn)
            allow(Rails.logger).to receive(:error)

            execute_call

            expect(Rails.logger).to have_received(:error).once
            expect(Rails.logger).not_to have_received(:warn)
          end
        end

        context "custom leniency is set" do
          before do
            Stitches.configuration.disabled_key_leniency_in_seconds = 100
            Stitches.configuration.disabled_key_leniency_error_log_threshold_in_seconds = 50
          end

          context "when disabled_at is set to an unacceptably long time" do
            let(:disabled_at) { 101.seconds.ago }

            it "forbids the call" do
              allow(Rails.logger).to receive(:error)
              execute_call

              expect_unauthorized
              expect(Rails.logger).to have_received(:error).once
            end
          end

          context "when disabled_at is set to a dangerously long time" do
            let(:disabled_at) { 75.seconds.ago }

            it "allows the call" do
              allow(Rails.logger).to receive(:error)

              execute_call

              expect(response.body).to include "Hello"
              expect(Rails.logger).to have_received(:error).once
            end
          end

          context "when disabled_at is set to a short time ago" do
            let(:disabled_at) { 25.seconds.ago }

            it "allows the call" do
              allow(Rails.logger).to receive(:warn)

              execute_call

              expect(response.body).to include "Hello"
              expect(Rails.logger).to have_received(:warn).once
            end
          end
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

  context "when schema is old and missing disabled_at field" do
    around(:each) do |example|
      load 'fake_app/db/schema_missing_disabled_at.rb'
      ApiClient.reset_column_information
      example.run
      load 'fake_app/db/schema_modern.rb'
      ApiClient.reset_column_information
    end

    context "when api_client is valid" do
      let!(:api_client) {
        uuid = SecureRandom.uuid
        ApiClient.create(name: "MyApiClient", key: uuid, created_at: Time.now(), enabled: true)
      }

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

    context "when api_client is not enabled" do
      let!(:api_client) {
        uuid = SecureRandom.uuid
        ApiClient.create(name: "MyApiClient", key: uuid, created_at: Time.now(), enabled: false)
      }

      it "rejects request" do
        execute_call

        expect_unauthorized
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
