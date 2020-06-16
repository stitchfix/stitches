require 'lru_redux'

module Stitches::CacheInjector
  MAX_ITEMS_IN_CACHE = ENV.fetch("API_KEY_CACHE_MAX_ITEMS", 100)
  CACHE_DURATION_IN_SECONDS = ENV.fetch("API_KEY_CACHE_DURATION", 5 * 60) # five minutes

  def self.inject
    ::ApiClient.define_singleton_method 'api_key_cache' do
      @api_key_cache ||= LruRedux::TTL::Cache.new(
        Stitches::CacheInjector::MAX_ITEMS_IN_CACHE,
        Stitches::CacheInjector::CACHE_DURATION_IN_SECONDS
      )
    end

    ::ApiClient.define_singleton_method 'clear_api_cache' do
      api_key_cache.clear
    end
  
    ::ApiClient.define_singleton_method 'fetch_for_key' do |key|
      if ::ApiClient.column_names.include?("enabled")
        api_key_cache.getset(key) do
          where(key: key, enabled: true).first
        end
      else
        ActiveSupport::Deprecation.warn('api_keys is missing "enabled" column.  Run "rails g stitches:add_enabled_to_api_clients"')
        api_key_cache.getset(key) do
          where(key: key).first
        end
      end
    end
  end
end