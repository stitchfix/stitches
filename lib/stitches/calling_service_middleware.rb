require_relative 'calling_service_client'

module Stitches
  # Rack middleware that populates the api_client env var from the
  # X-StitchFix-Calling-Service header when no other auth middleware
  # has already set it. This allows existing code that reads
  # api_client.name to work transparently after API keys are disabled.
  class CallingServiceMiddleware
    def initialize(app)
      @app = app
    end

    def call(env)
      client_key = Stitches.configuration.env_var_to_hold_api_client

      unless env[client_key]
        header_name = Stitches.configuration.calling_service_header
        header_name = CallingServiceName::DEFAULT_CALLING_SERVICE_HEADER unless header_name.present?
        rack_key = "HTTP_#{header_name.upcase.tr('-', '_')}"

        if (name = env[rack_key]).present?
          env[client_key] = CallingServiceClient.new(name)
        end
      end

      @app.call(env)
    end
  end
end
