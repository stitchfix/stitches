module Stitches
  def self.configure(&block)
    block.(configuration)
  end

  def self.configuration
    @configuration ||= Configuration.new
  end
end
require 'stitches/configuration'
require 'stitches/render_timestamps_in_iso8601_in_json'
require 'stitches/error'
require 'stitches/errors'
require 'stitches/api_generator'
require 'stitches/add_enabled_to_api_clients_generator'
require 'stitches/api_version_constraint'
require 'stitches/api_key'
require 'stitches/valid_mime_type'
