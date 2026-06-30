require 'rails_helper'

describe Stitches::CallingServiceMiddleware do
  let(:app) { ->(env) { [200, env, "OK"] } }
  let(:middleware) { described_class.new(app) }
  let(:env) { Rack::MockRequest.env_for("/api/test", method: "POST") }

  let(:client_key) { Stitches.configuration.env_var_to_hold_api_client }

  describe "#call" do
    context "when the header is present and env var is not set" do
      before { env["HTTP_X_STITCHFIX_CALLING_SERVICE"] = "my-app" }

      it "populates the env var with a CallingServiceClient" do
        _status, result_env, _body = middleware.call(env)
        client = result_env[client_key]

        expect(client).to be_a(Stitches::CallingServiceClient)
        expect(client.name).to eq("my-app")
        expect(client.id).to be_nil
        expect(client.key).to be_nil
      end
    end

    context "when the env var is already set (API key or JWT auth ran)" do
      let(:existing_client) { double("ApiClient", name: "existing-client", id: 42) }

      before do
        env[client_key] = existing_client
        env["HTTP_X_STITCHFIX_CALLING_SERVICE"] = "some-service"
      end

      it "does not overwrite the existing value" do
        _status, result_env, _body = middleware.call(env)
        expect(result_env[client_key]).to eq(existing_client)
      end
    end

    context "when the header is absent and env var is not set" do
      it "sets a fallback CallingServiceClient with empty name" do
        _status, result_env, _body = middleware.call(env)
        client = result_env[client_key]

        expect(client).to be_a(Stitches::CallingServiceClient)
        expect(client.name).to eq("")
      end
    end

    context "when the header is blank" do
      before { env["HTTP_X_STITCHFIX_CALLING_SERVICE"] = "" }

      it "sets a fallback CallingServiceClient with empty name" do
        _status, result_env, _body = middleware.call(env)
        client = result_env[client_key]

        expect(client).to be_a(Stitches::CallingServiceClient)
        expect(client.name).to eq("")
      end
    end

    context "with a custom configured header" do
      before do
        Stitches.configuration.calling_service_header = "X-Custom-Caller"
        env["HTTP_X_CUSTOM_CALLER"] = "custom-service"
      end

      after { Stitches.configuration.reset_to_defaults! }

      it "reads from the configured header" do
        _status, result_env, _body = middleware.call(env)
        client = result_env[client_key]

        expect(client).to be_a(Stitches::CallingServiceClient)
        expect(client.name).to eq("custom-service")
      end
    end
  end
end
