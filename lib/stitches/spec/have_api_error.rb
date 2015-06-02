# Expects a web response to have an error in our given format
RSpec::Matchers.define :have_api_error do |expected_fields|
  match do |response|
    if response.response_code == (expected_fields[:status] || 422)
      error = extract_error(response,expected_fields)
      if error
        expected_code = expected_fields.fetch(:code)
        expected_message = expected_fields.fetch(:message)
        error["code"] == expected_code && message_matches(error["message"],expected_message)
      else
        false
      end
    else
      false
    end
  end

  def extract_error(response,expected_fields)
    parsed_response = JSON.parse(response.body)
    parsed_response["errors"].detect { |error|
      error["code"] == expected_fields.fetch(:code)
    }
  end

  def message_matches(message,expected_message)
    if expected_message.kind_of?(Regexp)
      message =~ expected_message
    else
      message == expected_message
    end
  end

  failure_message do |response|
    if response.response_code != (expected_fields[:status] || 422)
      "HTTP status was #{response.response_code} and not 422"
    else
      error = extract_error(response,expected_fields)
      if error
        if error["code"] != expected_fields.fetch(:code)
          "Expected code to be '#{expected_fields[:code]}', but was '#{error['code']}'"
        else
          "Expected message to be '#{expected_fields[:message]}', but was '#{error['message']}'"
        end
      else
        "Could not find an error for code #{expected_fields[:code]} from #{response.body}"
      end
    end
  end
end

