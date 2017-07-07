require "logger"

module Remotenv

  module_function

  def logger
    @_logger ||= Remotenv::Logger.new(STDOUT)
  end

  def logger=(logger)
    @_logger = logger
  end

  class Logger < ::Logger
    def initialize(*args)
      super
      @progname = "remotenv"
      log_level = (ENV["REMOTENV_LOG_LEVEL"] || ENV["LOG_LEVEL"] || "").upcase
      @level = ["DEBUG", "INFO", "WARN", "ERROR", "FATAL", "UNKNOWN"].index(log_level) != nil ? Logger.const_get(log_level) : Logger::INFO
    end
  end
end
