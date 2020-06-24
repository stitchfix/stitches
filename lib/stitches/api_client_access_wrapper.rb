require 'lru_redux'

module Stitches::ApiClientAccessWrapper

  def self.fetch_for_key(key)
    api_key_cache.getset(key) do
      fetch_for_key_from_db(key)
    end
  end

  def self.fetch_for_key_from_cache(key)
    api_key_cache.getset(key) do
      fetch_for_key_from_db(key)
    end
  end

  def self.fetch_for_key_from_db(key)
    if ::ApiClient.column_names.include?("enabled")
      ::ApiClient.find_by(key: key, enabled: true)
    else
      ActiveSupport::Deprecation.warn('api_keys is missing "enabled" column.  Run "rails g stitches:add_enabled_to_api_clients"')
      ::ApiClient.find_by(key: key)
    end
  end

  def self.clear_api_cache
    api_key_cache.clear
  end

  def self.api_key_cache
    @api_key_cache ||= LruRedux::TTL::ThreadSafeCache.new(
      Stitches.configuration.max_cache_size,
      Stitches.configuration.max_cache_ttl,
    )
  end
end