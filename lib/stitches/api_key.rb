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

    def initialize(app,options = {})
      super(app,options)
      @realm = rails_app_module
    end

  protected

    def do_call(env)
      authorization = env["HTTP_AUTHORIZATION"]
      if authorization
        if authorization =~ /#{@configuration.custom_http_auth_scheme}\s+key=(.*)\s*$/
          key = $1

          if ApiClient.column_names.include?("enabled")
            client = ApiClient.where(key: key, enabled: true).first
          else
            ActiveSupport::Deprecation.warn('api_keys is missing "enabled" column.  Run "rails g stitches:add_enabled_to_api_clients"')
            client = ApiClient.where(key: key).first
          end

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

    class UnauthorizedResponse

      attr_accessor :status, :body
      attr_reader :header
      alias headers header

      def initialize(reason, realm, custom_http_auth_scheme)
        @status = 401
        @header = Rack::Utils::HeaderHash.new({ "WWW-Authenticate" => "#{custom_http_auth_scheme} realm=#{realm}" })
        @body = ["Unauthorized - #{reason}"]
      end

      def to_ary
        [status, headers, body]
      end
    end

  end
end
