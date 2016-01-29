require_relative 'whitelisting_middleware'

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
  class ApiKey < Stitches::WhitelistingMiddleware

    def initialize(app,options = {})
      super(app,options)
      @realm = Rails.application.class.parent.to_s
    end

  protected

    def do_call(env)
      return if @configuration.disable_authorization || ENV['DISABLE_API_AUTHORIZATION'] == 'true'

      authorization = env["HTTP_AUTHORIZATION"]
      if authorization
        if authorization =~ /#{@configuration.custom_http_auth_scheme}\s+key=(.*)\s*$/
          key = $1
          client = ::ApiClient.where(key: key).first
          if client.present?
            env[@configuration.env_var_to_hold_api_client_primary_key] = client.id
            env[@configuration.env_var_to_hold_api_client] = client
            @app.call(env)
          else
            UnauthorizedResponse.new("key invalid",@realm,@configuration.custom_http_auth_scheme)
          end
        else
          UnauthorizedResponse.new("bad authorization type",@realm,@configuration.custom_http_auth_scheme)
        end
      else
        UnauthorizedResponse.new("no authorization header",@realm,@configuration.custom_http_auth_scheme)
      end
    end

  private

    class UnauthorizedResponse < Rack::Response
      def initialize(reason,realm,custom_http_auth_scheme)
        super("Unauthorized - #{reason}", 401, { "WWW-Authenticate" => "#{custom_http_auth_scheme} realm=#{realm}" })
      end
    end

  end
end
