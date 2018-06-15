# Use this to test that an HTTP response is properly "410/Gone"
#
# The object you expect on is generally `self`, because this is the object on which
# rspec_api_documentation allows you to call `status`
#
# get "/api/widgets" do
#   it "has been removed" do
#     expect(self).to be_gone
#   end
# end
RSpec::Matchers.define :be_gone do
  match do |rspec_api_documentation_context|
    rspec_api_documentation_context.status == 410
  end
  failure_message do |rspec_api_documentation_context|
    "Expected HTTP status to be 410/Gone, but it was #{rspec_api_documentation_context.status}"
  end
end

