module Stitches
  module CallingServiceName
    def calling_service_name
      @calling_service_name ||=
        request.headers[Stitches.configuration.calling_service_header].presence || ""
    end
  end
end
