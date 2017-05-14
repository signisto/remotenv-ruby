require "redis"
require "logger"

require "envoku/version"
require "envoku/adapters/base"
require "envoku/adapters/http"
require "envoku/adapters/s3"
require "envoku/feature"
require "envoku/logger"
require "envoku/resource"
require "envoku/utils"

Dotenv.load("#{Dir.pwd}/.env") if defined?(Dotenv) && ENV['RAILS_ENV'] != "test"

require "envoku/rails" if defined?(Rails)

module Envoku

  URL = Envoku::Utils.parsed_url
  URI = Envoku::Utils.parsed_uri

  module_function

  def load(options = {})
    adapter = Envoku::Adapters.for(Envoku::Utils.parsed_uri)
    adapter.load!
    @data = data.merge(adapter.data)
  end

  def data
    @data || {}
  end

  def get(key)
    return nil unless @data
    @data[key]
  end

  def set(key, value)
    return nil unless @data
    @data[key] = value
  end

  def redis
    @redis ||= ::Redis.new(
      url: (ENV['ENVOKU_REDIS_URL'] || ENV['REDIS_URL']),
    )
  end
end
