module Stitches
  module CallingServiceName
    HEADER = "X-StitchFix-Calling-Service"

    def calling_service_name
      @calling_service_name ||=
        request.headers[HEADER].presence ||
        api_client&.name ||
        "unknown"
    end
  end
end
