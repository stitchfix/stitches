require 'lru_redux'

module Stitches::ApiKeyCacheWrapper

  def self.api_key_cache
    @api_key_cache ||= LruRedux::TTL::ThreadSafeCache.new(
      Stitches.configuration.max_cache_size,
      Stitches.configuration.max_cache_ttl,
    )
  end

  def self.fetch_for_key(key)
    if ::ApiClient.column_names.include?("enabled")
      api_key_cache.getset(key) do
        ApiClient.find_by(key: key, enabled: true)
      end
    else
      ActiveSupport::Deprecation.warn('api_keys is missing "enabled" column.  Run "rails g stitches:add_enabled_to_api_clients"')
      api_key_cache.getset(key) do
        ApiClient.find_by(key: key)
      end
    end
  end

  def self.clear_api_cache
    api_key_cache.clear
  end
end