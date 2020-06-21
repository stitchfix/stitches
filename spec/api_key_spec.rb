require 'spec_helper.rb'

module MyApp
  class Application
  end
end

unless defined? ApiClient
  class ApiClient
    def self.column_names
      ["enabled"]
    end
  end
end

describe Stitches::ApiKey do
  let(:app) { double("rack app") }
  let(:api_client) {
    double(ApiClient, id: 42)
  }

  before do
    Stitches.configuration.reset_to_defaults!
    Stitches.configuration.custom_http_auth_scheme = 'MyAwesomeInternalScheme'
    fake_rails_app = MyApp::Application.new
    allow(Rails).to receive(:application).and_return(fake_rails_app)
    allow(app).to receive(:call).with(env)
    allow(ApiClient).to receive(:find_by).and_return(api_client)
    Stitches::ApiKeyCacheWrapper.clear_api_cache
  end

  subject(:middleware) { described_class.new(app, namespace: "/api") }

  shared_examples "an unauthorized response" do
    it "returns a 401" do
      status, _headers, _body = @response
      expect(status).to eq(401)
    end
    it "sets the proper header" do
      _status, headers, _body = @response
      expect(headers["WWW-Authenticate"]).to eq("MyAwesomeInternalScheme realm=MyApp")
    end
    it "stops the call chain preventing anything from happening" do
      expect(app).not_to have_received(:call)
    end
    it "sends a reasonable message" do
      _status, _headers, body = @response
      expect(body).to eq([expected_body])
    end
  end

  describe "#call" do
    context "not in namespace" do
      context "not allowlisted" do
        let(:env) {
          {
            "PATH_INFO" => "/index/apifoolingyou/home",
          }
        }

        before do
          @response = middleware.call(env)
        end

        it_behaves_like "an unauthorized response" do
          let(:expected_body) { "Unauthorized - no authorization header" }
        end
      end
      context "allowlisting" do
        context "allowlist is explicit in middleware usage" do
          before do
            @response = middleware.call(env)
          end
          context "passes the allowlist" do
            subject(:middleware) { described_class.new(app, except: %r{\A/resque\/.*\Z}) }
            let(:env) {
              {
                "PATH_INFO" => "/resque/overview"
              }
            }
            it "calls through to the rest of the chain" do
              expect(app).to have_received(:call).with(env)
            end
          end

          context "fails the allowlist" do
            subject(:middleware) { described_class.new(app, except: %r{\A/resque\/.*\Z}) }
            let(:env) {
              {
                "PATH_INFO" => "//resque/overview" # subtle
              }
            }
            it_behaves_like "an unauthorized response" do
              let(:expected_body) { "Unauthorized - no authorization header" }
            end
          end
          context "except: is not given a regexp" do
            let(:env) {
              {
                "PATH_INFO" => "//resque/overview" # subtle
              }
            }
            it "blows up" do
              expect {
                described_class.new(app, except: "/resque")
              }.to raise_error(/must be a Regexp/i)
            end
          end
        end
        context "allowlist is implicit from the configuration" do

          before do
            Stitches.configuration.allowlist_regexp = %r{\A/resque/.*\Z}
            @response = middleware.call(env)
          end

          context "passes the allowlist" do
            subject(:middleware) { described_class.new(app) }
            let(:env) {
              {
                "PATH_INFO" => "/resque/overview"
              }
            }
            it "calls through to the rest of the chain" do
              expect(app).to have_received(:call).with(env)
            end
          end

          context "fails the allowlist" do
            subject(:middleware) { described_class.new(app) }
            let(:env) {
              {
                "PATH_INFO" => "//resque/overview" # subtle
              }
            }
            it_behaves_like "an unauthorized response" do
              let(:expected_body) { "Unauthorized - no authorization header" }
            end
          end
        end
      end
    end

    context "valid key" do
      let(:env) {
        {
          "PATH_INFO" => "/api/ping",
          "HTTP_AUTHORIZATION" => "MyAwesomeInternalScheme key=foobar",
        }
      }

      before do
        @response = middleware.call(env)
      end
      it "calls through to the rest of the chain" do
        expect(app).to have_received(:call).with(env)
      end

      it "sets the api_client's ID in the environment" do
        expect(env[Stitches.configuration.env_var_to_hold_api_client_primary_key]).to eq(api_client.id)
      end

      it "sets the api_client itself in the environment" do
        expect(env[Stitches.configuration.env_var_to_hold_api_client]).to eq(api_client)
      end
    end

    context "unauthorized responses" do
      before do
        @response = middleware.call(env)
      end
      context "invalid key" do
        let(:env) {
          {
            "PATH_INFO" => "/api/ping",
            "HTTP_AUTHORIZATION" => "MyAwesomeInternalScheme key=foobar",
          }
        }
        let(:api_client) { nil }

        it_behaves_like "an unauthorized response" do
          let(:expected_body) { "Unauthorized - key invalid" }
        end
      end
      context "bad authorization type" do
        let(:env) {
          {
            "PATH_INFO" => "/api/ping",
            "HTTP_AUTHORIZATION" => "foobar",
          }
        }
        it_behaves_like "an unauthorized response" do
          let(:expected_body) { "Unauthorized - bad authorization type" }
        end
      end
      context "no auth header" do
        let(:env) {
          {
            "PATH_INFO" => "/api/ping",
          }
        }
        it_behaves_like "an unauthorized response" do
          let(:expected_body) { "Unauthorized - no authorization header" }
        end
      end
    end
  end
end
