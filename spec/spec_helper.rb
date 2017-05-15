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
      'ENVOKU_URL',
      'ENVOKU_REDIS_URL',
      'REDIS_URL',
      'LOG_LEVEL',
      'ENVOKU_LOG_LEVEL',
    ].each { |key| ENV.delete(key) }
    stub_const("Envoku::URL", nil)
    stub_const("Envoku::URI", nil)
    Envoku.logger = nil
    Envoku.logger.level = :fatal
  end
end
