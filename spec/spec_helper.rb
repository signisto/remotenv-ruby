$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'simplecov'
require 'envoku'

RSpec.configure do |config|

  config.before :each do
    stub_const('Envoku::Feature::REDIS_NAMESPACE', 'envoku:test:features:')
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
    ENV.select { |key, value| key.index(Envoku::Feature::ENV_NAMESPACE) == 0 }.keys.each do |key|
      ENV.delete(key)
    end
    Envoku.instance_variable_set(:'@redis', nil)
    stub_const("Envoku::URL", nil)
    stub_const("Envoku::URI", nil)
    Envoku.logger = nil
    Envoku.logger.level = :fatal
  end

  config.after :each do
    if Envoku.instance_variable_get(:'@redis')
      keys = Envoku.redis.keys("#{Envoku::Feature::REDIS_NAMESPACE}*")
      Envoku.redis.del(*keys) if keys.count > 0
    end
  end

end

class DummyResource
  attr_accessor :id
  def initialize(attributes = {})
    attributes.each { |key, value| send("#{key}=", value) }
  end
end
