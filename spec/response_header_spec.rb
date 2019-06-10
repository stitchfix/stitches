require 'spec_helper.rb'

describe Stitches::ResponseHeader do
    let(:app) { double("rack app") }
    let(:headers) { {"Content-Type" => ""} }

    before do
      allow(app).to receive(:call).with(env).and_return([nil, headers, nil])
    end

    subject(:middleware) { described_class.new(app, namespace: "/api") }

    describe "#call" do
      context "valid header" do
        let(:env) {
          {
            "PATH_INFO" => "/api/ping",
            "HTTP_ACCEPT" => "application/json; version=99",
            "CONTENT_TYPE" => "application/json; version=99"
          }
        }

        before do
          @response = middleware.call(env)
        end
        it "calls through to the rest of the chain" do
          expect(app).to have_received(:call).with(env)
        end

        it "has the Content-Type version information" do
           expect(@response[1]["Content-Type"]).to eq("application/json; version=99")
        end
      end
    end
  end