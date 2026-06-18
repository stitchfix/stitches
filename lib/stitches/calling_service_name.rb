module Stitches
  module CallingServiceName
    DEFAULT_CALLING_SERVICE_HEADER = "X-StitchFix-Calling-Service"

    def calling_service_name
      @calling_service_name ||=
        request.headers[calling_service_header_name].presence || ""
    end

    private

    def calling_service_header_name
      configured = Stitches.configuration.calling_service_header
      configured.present? ? configured : DEFAULT_CALLING_SERVICE_HEADER
    end
  end
end
