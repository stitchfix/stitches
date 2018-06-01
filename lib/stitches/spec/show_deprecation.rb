class DeprecationAnalysis
  attr_reader :expected_sunset_value, :status, :sunset_value
  def initialize(rspec_api_documentation_context, retiring_on)
    retiring_on_date = Date.parse(retiring_on)
    if retiring_on_date > Date.today
      @expecting_sunset      = true
      @expected_sunset_value = retiring_on_date.in_time_zone("GMT").midnight.strftime("%a, %e %b %Y %H:%M:%S %Z")
      @sunset_header_set     = rspec_api_documentation_context.response_headers["Sunset"].present?
      @sunset_value          = rspec_api_documentation_context.response_headers["Sunset"]
      @sunset_header_match   = @expected_sunset_value == @sunset_value
    else
      @expecting_gone = true
      @status         = rspec_api_documentation_context.status
      @gone           = @status == 410
    end
  end

  def expecting_sunset?;    !!@expecting_sunset;    end
  def sunset_header_set?;   !!@sunset_header_set;   end
  def sunset_header_match?; !!@sunset_header_match; end
  def gone?;                !!@gone;                end
end

RSpec::Matchers.define :show_deprecation do |retiring_on:|
  match do |rspec_api_documentation_context|
    analysis = DeprecationAnalysis.new(rspec_api_documentation_context,retiring_on)
    if analysis.expecting_sunset?
      analysis.sunset_header_match?
    else
      analysis.gone?
    end
  end
  failure_message do |rspec_api_documentation_context|
    analysis = DeprecationAnalysis.new(rspec_api_documentation_context,retiring_on)
    if analysis.expecting_sunset?
      if analysis.sunset_header_set?
        "Expected the Sunset header to be #{analysis.expected_sunset_value}, but was '#{analysis.sunset_value}'"
      else
        "No Sunset header was set.  Use the deprecation method from Stitches::Deprecation in the controller method to deprecate this action"
      end
    else
      "Since the deprecation date has passed, expected HTTP status to be 410/Gone, but it was #{analysis.status}.  Re-implement the endpoint using `gone!` and then change the test to expect it to `be_gone`"
    end
  end
end

