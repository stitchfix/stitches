module Stitches
  module CallingServiceName
    HEADER = "X-StitchFix-Calling-Service"

    def calling_service_name
      @calling_service_name ||=
        request.headers[HEADER].presence ||
        request.env[Stitches.configuration.env_var_to_hold_api_client]&.name ||
        ""
    end
  end
end
