require_relative 'calling_service_client'

module Stitches
  # Rack middleware that populates the caller identity env var from the
  # calling service header when no other auth middleware has already set
  # it. This allows existing code that reads the caller identity object
  # to work transparently after API keys are disabled.
  class CallingServiceMiddleware
    def initialize(app)
      @app = app
    end

    def call(env)
      client_key = Stitches.configuration.env_var_to_hold_api_client

      unless env[client_key]
        header_name = Stitches.configuration.calling_service_header
        rack_key = "HTTP_#{header_name.upcase.tr('-', '_')}"

        name = env[rack_key].presence || ""
        env[client_key] = CallingServiceClient.new(name)
      end

      @app.call(env)
    end
  end
end
