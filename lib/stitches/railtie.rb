require 'stitches/api_key'
require 'stitches/valid_mime_type'

module Stitches
  class Railtie < Rails::Railtie
    config.app_middleware.use Stitches::ApiKey
    config.app_middleware.use Stitches::ValidMimeType
  end
end
