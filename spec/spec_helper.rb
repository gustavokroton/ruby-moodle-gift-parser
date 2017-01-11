#ref http://stackoverflow.com/questions/4398262/setup-rspec-to-test-a-gem-not-rails
require 'bundler/setup'
Bundler.setup

require 'moodle_gift'
#require 'your_gem_name' # and any other gems you need

RSpec.configure do |config|
#  config.color_enabled = true
  config.formatter     = 'documentation'
end
