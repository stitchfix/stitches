require 'lru_redux'

module Stitches::ApiClientAccessWrapper

  def self.fetch_for_key(key, configuration)
    if cache_enabled
      fetch_for_key_from_cache(key, configuration)
    else
      fetch_for_key_from_db(key, configuration)
    end
  end

  def self.fetch_for_key_from_cache(key, configuration)
    api_key_cache.getset(key) do
      fetch_for_key_from_db(key, configuration)
    end
  end

  def self.fetch_for_key_from_db(key, configuration)
    api_client = ::ApiClient.find_by(key: key)
    return unless api_client

    unless api_client.respond_to?(:enabled?)
      logger.warn('api_keys is missing "enabled" column.  Run "rails g stitches:add_enabled_to_api_clients"')
      return api_client
    end

    unless api_client.respond_to?(:disabled_at)
      logger.warn('api_keys is missing "disabled_at" column.  Run "rails g stitches:add_disabled_at_to_api_clients"')
    end

    return api_client if api_client.enabled?

    disabled_at = api_client.respond_to?(:disabled_at) ? api_client.disabled_at : nil
    if disabled_at && disabled_at > configuration.disabled_key_leniency_in_seconds.seconds.ago
      message = "Allowing disabled ApiClient: #{api_client.name} with key #{redact_key(api_client)} disabled at #{disabled_at}"
      if disabled_at > configuration.disabled_key_leniency_error_log_threshold_in_seconds.seconds.ago
        logger.warn(message)
      else
        logger.error(message)
      end
      return api_client
    else
      logger.error("Rejecting disabled ApiClient: #{api_client.name} with key #{redact_key(api_client)}")
    end
    nil
  end

  def self.redact_key(api_client)
    "*****#{api_client.key.to_s[-8..-1]}"
  end

  def self.logger
    if defined?(StitchFix::Logger::LogWriter)
      StitchFix::Logger::LogWriter
    elsif defined?(Rails.logger)
      Rails.logger
    else
      ::Logger.new('/dev/null')
    end
  end

  def self.clear_api_cache
    api_key_cache.clear if cache_enabled
  end

  def self.api_key_cache
    @api_key_cache ||= LruRedux::TTL::ThreadSafeCache.new(
      Stitches.configuration.ignore_nil,
      Stitches.configuration.max_cache_size,
      Stitches.configuration.max_cache_ttl,
    )
  end

  def self.cache_enabled
    Stitches.configuration.max_cache_ttl.positive?
  end
end
