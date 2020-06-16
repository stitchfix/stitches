require 'stitches/api_key'
require 'stitches/valid_mime_type'
require 'stitches/cache_injector'

module Stitches
  class Railtie < Rails::Railtie
    config.app_middleware.use Stitches::ApiKey
    config.app_middleware.use Stitches::ValidMimeType

    Stitches::CacheInjector.inject if defined? ApiClient
  end
end
