require 'spec_helper.rb'
require 'stitches/spec'

describe "show_deprecation" do
  context "when the expiration date is in the future" do
    it "passes if the sunset header is set properly" do
      rspec_api_documentation_context = double(
        "a test using rspec_api_documentation",
        status: 200,
        response_headers: { "Sunset" => "Mon, 13 Dec 2038 00:00:00 GMT" }
      )

      expect(rspec_api_documentation_context).to show_deprecation(retiring_on: "2038-12-13")
    end
    it "fails if the sunset header is not set" do
      begin
        rspec_api_documentation_context = double( "a test using rspec_api_documentation", status: 200, response_headers: {})
        expect(rspec_api_documentation_context).to show_deprecation(retiring_on: "2038-12-13")
        fail "Expected matcher to fail"
      rescue RSpec::Expectations::ExpectationNotMetError => e
        expect(e.message).to match(/No Sunset header was set/i)
      end
    end
    it "fails if the sunset header is the wrong date" do
      begin
        rspec_api_documentation_context = double(
          "a test using rspec_api_documentation",
          status: 200,
          response_headers: { "Sunset" => "Tuesday, 14 Dec 2038 00:00:00 GMT" }
        )
        expect(rspec_api_documentation_context).to show_deprecation(retiring_on: "2038-12-13")
        fail "Expected matcher to fail"
      rescue RSpec::Expectations::ExpectationNotMetError => e
        expect(e.message).to match(/Expected the Sunset header to be Mon, 13 Dec 2038 00:00:00 GMT, but was 'Tuesday, 14 Dec 2038 00:00:00 GMT/i)
      end
    end
  end
  context "when the expiration date is in the past" do
    it "passes if the http status is 410/gone" do
      rspec_api_documentation_context = double("a test using rspec_api_documentation", status: 410)
      expect(rspec_api_documentation_context).to show_deprecation(retiring_on: "2011-01-01")
    end

    it "fails if the status is not 410/gone" do
      rspec_api_documentation_context = double("a test using rspec_api_documentation", status: 200)
      begin
        expect(rspec_api_documentation_context).to show_deprecation(retiring_on: "2011-01-01")
        fail "Expected matcher to fail"
      rescue RSpec::Expectations::ExpectationNotMetError => e
        expect(e.message).to match(/deprecation date has passed.*410.*using `gone\!`/i)
      end
    end
  end
end
