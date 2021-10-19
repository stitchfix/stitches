require 'stitches'

Stitches.configure do |configuration|
  # Regexp of urls that do not require ApiKeys or valid, versioned mime types
  configuration.allowlist_regexp = %r{\A/(resque|docs|assets)(\Z|/.*\Z)}

  # Name of the custom Authorization scheme.  See http://www.ietf.org/rfc/rfc2617.txt for details,
  # but generally should be a string with no spaces or special characters.
  configuration.custom_http_auth_scheme = "CustomKeyAuth"

  # Env var that gets the primary key of the authenticated ApiKey
  # for access in your controllers, so they don't need to re-parse the header
  # configuration.env_var_to_hold_api_client_primary_key = "YOUR_ENV_VAR"

  # Configures how long to cache ApiKeys in memory (In Seconds)
  # A value of 0 will disable the cache entierly
  # Default is 0
  # configuration.max_cache_ttl = 5

  # Configures how many ApiKeys to cache at one time
  # This should be larger then the number of clients
  # Default is 0
  # configuration.max_cache_size = 100
end
