require_relative 'allowlist_middleware'

module Stitches
  # A middleware that requires an API key for certain transactions, and makes its id available
  # in the enviornment for controllers.
  #
  # This follows http://www.ietf.org/rfc/rfc2617.txt for use of custom authorization methods, namely
  # the specification of an API key.
  #
  # Apps are expected to set the Authorization header (available to Rack apps as the environment
  # variable HTTP_AUTHORIZATION) to
  #
  #     MyInternalRealm key=<<api key>>
  #
  # where MyInternalRealm is the value returned by Stitches.configuration.custom_http_auth_scheme and
  # <<api key>> is the UUID provided to the caller.  It's expected that there is an entry
  # in the API_CLIENTS table with this value for "key".
  #
  # If that is the case, env[Stitches.configuration.env_var_to_hold_api_client_primary_key] will be the primary key of the
  # ApiClient that it maps to.
  class ApiKey < Stitches::AllowlistMiddleware

  protected

    def do_call(env)
      return @app.call(env) if Stitches.configuration.disable_api_key_support

      authorization = env["HTTP_AUTHORIZATION"]
      if authorization
        if authorization =~ /#{configuration.custom_http_auth_scheme}\s+key=(.*)\s*$/
          key = $1
          client = Stitches::ApiClientAccessWrapper.fetch_for_key(key, configuration)
          if client.present?
            env[configuration.env_var_to_hold_api_client_primary_key] = client.id
            env[configuration.env_var_to_hold_api_client] = client
            @app.call(env)
          else
            unauthorized_response("key invalid")
          end
        else
          unauthorized_response("bad authorization type")
        end
      else
        message = "no authorization header"

        if Rails.env.test? || Rails.env.development?
          message += " (Development/Test Env Hint: Blocked by stitches; confirm your authorization header is set OR check the `allowlist_regex` config for this path)"
        end

        unauthorized_response(message)
      end
    end

  private

    # TODO: (jdlubrano)
    # Once Rails 5 support is no longer necessary, we can simply call
    # Rails.application.class.module_parent.  The module_parent method
    # does not exist in Rails <= 5, though, so we need to gracefully fallback
    # Rails.application.class.parent for Rails versions predating Rails 6.0.0.
    def rails_app_module
      application_class = Rails.application.class
      parent = application_class.try(:module_parent) || application_class.parent
      parent.to_s
    end

    def unauthorized_response(reason)
      status = 401
      body = "Unauthorized - #{reason}"
      header = { "WWW-Authenticate" => "#{configuration.custom_http_auth_scheme} realm=#{rails_app_module}" }
      Rack::Response.new(body, status, header).finish
    end

  end
end
