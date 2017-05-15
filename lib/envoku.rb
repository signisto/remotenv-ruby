require "logger"

require "envoku/version"
require "envoku/adapters/base"
require "envoku/adapters/http"
require "envoku/adapters/s3"
require "envoku/logger"
require "envoku/utils"

Dotenv.load("#{Dir.pwd}/.env") if defined?(Dotenv) && ENV['RAILS_ENV'] != "test"

require "envoku/rails" if defined?(Rails)

module Envoku
  module_function

  def url
    @_url ||= Envoku::Utils.parsed_url
  end

  def uri
    @_uri ||= Envoku::Utils.parsed_uri
  end

  def load(options = {})
    adapter = Envoku::Adapters.for(self.uri)
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
end
