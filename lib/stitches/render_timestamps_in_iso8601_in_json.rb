require 'active_support/time_with_zone'

class ActiveSupport::TimeWithZone
  # We want dates to be a) in UTC and b) in ISO8601 always
  def as_json(options = {})
    utc.iso8601
  end
end

