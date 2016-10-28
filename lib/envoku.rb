require "redis"
require "logger"

require "envoku/version"
require "envoku/adapters/s3"
require "envoku/feature"
require "envoku/logger"
require "envoku/resource"
require "envoku/utils"

require "envoku/rails" if defined?(Rails)

module Envoku

  URL = Envoku::Utils.parsed_url
  URI = Envoku::Utils.parsed_uri

  module_function

  def load(options = {})
    Envoku.logger.debug("load")
    instance = Envoku::Adapters::S3.new(options)
    instance.load
  end

  def get_all
    adapter = Envoku::Adapters::S3.new
    adapter.load
    adapter.get_all
  end

  def get(key)
    adapter = Envoku::Adapters::S3.new
    adapter.load
    adapter.get(key)
  end

  def set(key, value)
    adapter = Envoku::Adapters::S3.new
    adapter.load
    adapter.set(key, value)
  end

  def redis
    @redis ||= ::Redis.new(
      url: (ENV['ENVOKU_REDIS_URL'] || ENV['REDIS_URL']),
    )
  end
end
