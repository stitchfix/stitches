require 'spec_helper.rb'

describe Stitches::Deprecation do
  let(:response) {
    double("response").tap { |r|
      allow(r).to receive(:set_header)
    }
  }
  let(:request) { double("request", method: "PUT", fullpath: "/foo/bar?blah") }
  let(:api_client) { double("ApiClient", id: 99) }
  let(:fake_controller) {
    double("Controller", response: response, request: request, current_user: api_client).extend(described_class).tap { |controller|
      allow(controller).to receive(:head)
    }
  }
  describe "#gone" do
    it "sends an HTTP 410" do
      fake_controller.gone!
      expect(fake_controller).to have_received(:head).with(410)
    end
  end

  describe "#deprecated" do
    let(:logger) { double("logger") }
    before do
      allow(Rails).to receive(:logger).and_return(logger)
      allow(logger).to receive(:info)
    end
    it "sets the Sunset header to the date given in GMT" do
      fake_controller.deprecated(gone_on: "2018-01-01") {}
      expect(response).to have_received(:set_header).with("Sunset","Mon,  1 Jan 2018 00:00:00 GMT")
    end
    it "logs about the request and current API key id" do
      fake_controller.deprecated(gone_on: "2018-01-01") {}
      expect(logger).to have_received(:info).with(/deprecated.*#{Regexp.escape(request.method)}.*#{Regexp.escape(request.fullpath)}.*#{Regexp.escape(api_client.id.to_s)}/i)
    end
    it "executes and returns the block" do
      block_executed = false
      result = fake_controller.deprecated(gone_on: "2018-01-01") do
        block_executed = true
        42
      end
      aggregate_failures do
        expect(result).to eq(42)
        expect(block_executed).to eq(true)
      end
    end
  end
end
