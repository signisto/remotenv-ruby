$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'simplecov'
require 'remotenv'

RSpec.configure do |config|

  config.before :each do
    [
      'AWS_ACCESS_KEY_ID',
      'AWS_SECRET_ACCESS_KEY',
      'REMOTENV_BUCKET',
      'REMOTENV_REFRESHED_AT',
      'REMOTENV_URL',
      'LOG_LEVEL',
      'REMOTENV_LOG_LEVEL',
    ].each { |key| ENV.delete(key) }
    Remotenv.logger = nil
    Remotenv.logger.level = :fatal
  end
end
