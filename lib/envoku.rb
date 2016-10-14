require "redis"

require "envoku/version"
require "envoku/adapters/s3"
require "envoku/feature"
require "envoku/rails" if defined?(Rails)

module Envoku

  module_function

  def load(options = {})
    instance = Envoku::Adapters::S3.new options
    instance.load
  end

  def redis
    @redis ||= ::Redis.new(
      url: (ENV['ENVOKU_REDIS_URL'] || ENV['REDIS_URL']),
    )
  end

  def feature_enabled_for?(feature_name, resource)
    Envoku::Feature.new(feature_name).enabled_for?(resource)
  end

  def features_for(resource)
    redis.smembers("envoku:features:#{resource.class.name}:#{resource.id}")
  end
end
