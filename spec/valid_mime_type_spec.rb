require 'spec_helper.rb'

describe Stitches::ValidMimeType do
  let(:app) { double("rack app") }
  
  before do
    allow(app).to receive(:call).with(env)
  end

  subject(:middleware) { described_class.new(app, namespace: "/api") }

  shared_examples "an unacceptable response" do
    it "returns a 406" do
      status, _headers, _body = @response
      expect(status).to eq(406)
    end
    it "stops the call chain preventing anything from happening" do
      expect(app).not_to have_received(:call)
    end
    it "sends a reasonable message" do
      _status, _headers, body = @response
      expect(body.first).to match(/didn't have the right mime type or version number. We only accept application\/json/)
    end
  end

  describe "#call" do
    context "not in namespace" do
      context "not in allowlist" do
        let(:env) {
          {
            "PATH_INFO" => "/index/home",
          }
        }

        before do
          @response = middleware.call(env)
        end

        it_behaves_like "an unacceptable response"
      end
      context "allowlisting" do
        let(:env) {
          {
            "PATH_INFO" => "/index/home",
          }
        }

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
            it_behaves_like "an unacceptable response"
          end
          context "except: is not given a regexp" do
            let(:env) {
              {
                "PATH_INFO" => "//resque/overview"
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
            it_behaves_like "an unacceptable response"
          end
        end
      end
    end

    context "valid header" do
      let(:env) {
        {
          "PATH_INFO" => "/api/ping",
          "HTTP_ACCEPT" => "application/json; version=99",
        }
      }

      before do
        @response = middleware.call(env)
      end
      it "calls through to the rest of the chain" do
        expect(app).to have_received(:call).with(env)
      end
    end

    context "unacceptable responses" do
      before do
        @response = middleware.call(env)
      end
      context "no header" do
        let(:env) {
          {
            "PATH_INFO" => "/api/ping",
          }
        }
        it_behaves_like "an unacceptable response"
      end
      context "bad mime type" do
        let(:env) {
          {
            "PATH_INFO" => "/api/ping",
            "HTTP_ACCEPT" => "application/json; version=bleorgh",
          }
        }
        it_behaves_like "an unacceptable response"
      end
      context "bad version" do
        let(:env) {
          {
            "PATH_INFO" => "/api/ping",
            "HTTP_ACCEPT" => "application/xml; version=1",
          }
        }
        it_behaves_like "an unacceptable response"
      end
    end
  end
end
