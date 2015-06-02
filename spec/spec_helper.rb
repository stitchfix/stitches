GEM_ROOT = File.expand_path(File.join(File.dirname(__FILE__),'..'))
Dir["#{GEM_ROOT}/spec/support/**/*.rb"].sort.each {|f| require f}

require 'rails/all'
require 'stitches'

RSpec.configure do |config|
  config.order = "random"
end
I18n.enforce_available_locales = false # situps
