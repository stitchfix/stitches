module Stitches
  module CallingServiceName
    HEADER = "X-StitchFix-Calling-Service"

    def calling_service_name
      @calling_service_name ||=
        request.headers[HEADER].presence ||
        (respond_to?(:api_client, true) && api_client&.name) ||
        ""
    end
  end
end
