module Stitches
  module CallingServiceName
    def calling_service_name
      @calling_service_name ||=
        request.headers[Stitches.configuration.calling_service_header].presence ||
        request.env[Stitches.configuration.env_var_to_hold_api_client]&.name ||
        ""
    end
  end
end
