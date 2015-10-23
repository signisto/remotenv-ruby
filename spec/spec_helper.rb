$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'simplecov'
require 'envoku'

RSpec.configure do |config|

  config.before :each do
    ENV.keys.each { |k| ENV.delete k }
  end

end
