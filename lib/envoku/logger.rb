require "logger"

module Envoku

  module_function

  def logger
    @_logger ||= Envoku::Logger.new(STDOUT)
  end

  def logger=(logger)
    @_logger = logger
  end

  class Logger < ::Logger
    def initialize(*args)
      super
      @progname = "envoku"
      log_level = (ENV["ENVOKU_LOG_LEVEL"] || ENV["LOG_LEVEL"] || "").upcase
      @level = ["DEBUG", "INFO", "WARN", "ERROR", "FATAL", "UNKNOWN"].index(log_level) != nil ? Logger.const_get(log_level) : Logger::INFO
    end
  end
end
