require 'spec_helper.rb'
require 'stitches/spec'

describe "have_api_error" do
  let(:errors) {
    [
      { code: "foo", message: "bar" },
      { code: "baz", message: "quux" }
    ]
  }
  let(:response) {
    double(
      response_code: response_code,
      body: { errors: errors }.to_json)
  }
  context "missing required arguments from expectation" do
    let(:response_code) { 422 }
    it "blows up with a decent message" do
      expect {
        expect(response).to have_api_error(message: errors.first[:message])
      }.to raise_error(/key not found: :code/)
      expect {
        expect(response).to have_api_error(code: errors.first[:code])
      }.to raise_error(/key not found: :message/)
    end
  end
  context "no expected status specified" do
    context "status is 422" do
      let(:response_code) { 422 }
      context "an error in the expectation exists" do
        it "indicates there is an error" do
          expect(response).to have_api_error(errors.first)
        end
        it "indicates there is an error for another error in the errors list" do
          expect(response).to have_api_error(errors.second)
        end
        it "indicates there is an error via regexp" do
          expect(response).to have_api_error(code: errors.second[:code], message: /^.*$/)
        end
      end
      context "no error from the expectation exists" do
        it "indicates there is no error" do
          expect(response).not_to have_api_error(code: "blah", message: "crud")
        end
      end
    end
    context "status is 200" do
      let(:response_code) { 200 }
      it "indicates there is no error" do
        expect(response).not_to have_api_error(errors.first)
      end
    end
    context "status is e.g. 404" do
      let(:response_code) { 404 }
      it "indicates there is no error" do
        expect(response).not_to have_api_error(errors.first)
      end
    end
  end
  context "expected status is specified" do
    context "status is the expected status" do
      let(:response_code) { 404 }
      it "indicates there is an error" do
        expect(response).to have_api_error(status: 404,
                                           code: errors.first[:code],
                                           message: errors.first[:message])
      end
    end
    context "status is not the expected status" do
      let(:response_code) { 422 }
      it "indicates there is no error" do
        expect(response).not_to have_api_error(status: 404,
                                               code: errors.first[:code],
                                               message: errors.first[:bar])
      end
    end
  end
end
