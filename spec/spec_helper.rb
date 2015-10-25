$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'simplecov'
require 'envoku'

RSpec.configure do |config|

  config.before :each do
    [
      'AWS_ACCESS_KEY_ID',
      'AWS_SECRET_ACCESS_KEY',
      'ENVOKU_BUCKET',
      'ENVOKU_REFRESHED_AT',
    ].each { |key| ENV.delete(key) }
  end

end
