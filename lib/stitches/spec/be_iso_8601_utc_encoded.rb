RSpec::Matchers.define :be_iso8601_utc_encoded do 
  match do |string|
    string =~ /^\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\d[Zz]$/
  end

  failure_message_for_should do |string|
    "'#{string}' doesn't look like a UTC IS8601-encoded date"
  end
end

