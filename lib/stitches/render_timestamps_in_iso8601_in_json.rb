require 'active_support/time_with_zone'

class ActiveSupport::TimeWithZone
  # We want dates to always be in UTC
  def as_json(options = {})
    if utc?
      super
    else
      utc.as_json(options)
    end
  end
end

