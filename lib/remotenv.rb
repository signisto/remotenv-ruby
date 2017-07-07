require "logger"

require "remotenv/version"
require "remotenv/adapters/base"
require "remotenv/adapters/http"
require "remotenv/adapters/s3"
require "remotenv/logger"
require "remotenv/utils"

Dotenv.load("#{Dir.pwd}/.env") if defined?(Dotenv) && ENV['RAILS_ENV'] != "test"

require "remotenv/rails" if defined?(Rails)

module Remotenv
  module_function

  def url
    @_url ||= Remotenv::Utils.parsed_url
  end

  def uri
    @_uri ||= Remotenv::Utils.parsed_uri
  end

  def load(options = {})
    return unless self.uri
    adapter = Remotenv::Adapters.for(self.uri)
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
