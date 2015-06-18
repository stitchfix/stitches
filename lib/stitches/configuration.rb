module Stitches
end

class Stitches::Configuration

  def initialize
    reset_to_defaults!
  end

  # Mainly for testing, this resets all configuration to the default value
  def reset_to_defaults!
    @whitelist_regexp = nil
    @custom_http_auth_scheme = UnsetString.new("custom_http_auth_scheme")
    @env_var_to_hold_api_client_primary_key = NonNullString.new("env_var_to_hold_api_client_primary_key","STITCHES_API_CLIENT_ID")
    @env_var_to_hold_api_client= NonNullString.new("env_var_to_hold_api_client","STITCHES_API_CLIENT")
  end

  # A RegExp that whitelists URLS around the mime type and api key requirements.
  # nil means that ever request must have a proper mime type and api key.
  attr_reader :whitelist_regexp
  def whitelist_regexp=(new_whitelist_regexp)
    unless new_whitelist_regexp.nil? || new_whitelist_regexp.is_a?(Regexp)
      raise "whitelist_regexp must be a Regexp, not a #{new_whitelist_regexp.class}"
    end
    @whitelist_regexp = new_whitelist_regexp
  end

  # The name of your custom http auth scheme.  This must be set, and has no default
  def custom_http_auth_scheme
    @custom_http_auth_scheme.to_s
  end

  def custom_http_auth_scheme=(new_custom_http_auth_scheme)
    @custom_http_auth_scheme = NonNullString.new("custom_http_auth_scheme",new_custom_http_auth_scheme)
  end

  # The name of the environment variable that the ApiKey middleware should use to 
  # place the primary key of the authenticated ApiKey.  For example, if a user provides
  # the api key 1234-1234-1234-1234, and that maps to the primary key 42 in your database,
  # the environment will contain "42" in the key provided here.
  def env_var_to_hold_api_client_primary_key
    @env_var_to_hold_api_client_primary_key.to_s
  end

  def env_var_to_hold_api_client_primary_key=(new_env_var_to_hold_api_client_primary_key)
    @env_var_to_hold_api_client_primary_key = NonNullString.new("env_var_to_hold_api_client_primary_key",new_env_var_to_hold_api_client_primary_key)
  end

  def env_var_to_hold_api_client
    @env_var_to_hold_api_client.to_s
  end

  def env_var_to_hold_api_client=(new_env_var_to_hold_api_client)
    @env_var_to_hold_api_client= NonNullString.new("env_var_to_hold_api_client",new_env_var_to_hold_api_client)
  end

private

  class NonNullString
    def initialize(name,string)
      unless string.nil? || string.is_a?(String)
        raise "#{name} must be a String, not a #{string.class}"
      end
      if String(string).strip.length == 0
        raise "#{name} may not be blank"
      end
      @string = string
    end

    def to_s
      @string
    end
    alias :to_str :to_s
  end

  class UnsetString
    def initialize(name)
      @name = name
    end

    def to_s
      raise "You must set a value for #{@name} "
    end
    alias :to_str :to_s
  end
end
