require 'stitches/api_key'
require 'stitches/valid_mime_type'
require 'stitches/response_header'

module Stitches
  class Railtie < Rails::Railtie
    config.app_middleware.use Stitches::ApiKey
    config.app_middleware.use Stitches::ValidMimeType
    config.app_middleware.use Stitches::ResponseHeader
  end
end
