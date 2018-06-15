require 'spec_helper.rb'
require 'stitches/spec'

describe "be_gone" do
  it "passes the test if the http status was 410" do
    rspec_api_documentation_context = double("a test using rspec_api_documentation", status: 410)
    expect(rspec_api_documentation_context).to be_gone
  end
  it "fails the test if the http status was not 401" do
    rspec_api_documentation_context = double("a test using rspec_api_documentation", status: 200)
    begin
      expect(rspec_api_documentation_context).to be_gone
      fail "Expected the matcher to fail"
    rescue RSpec::Expectations::ExpectationNotMetError => e
      expect(e.message).to match(/expected http status.*410.*200/i)
    end
  end
end
