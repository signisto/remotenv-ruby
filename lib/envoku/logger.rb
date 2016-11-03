require "logger"

module Envoku

  module_function

  def logger
    @_logger
  end

  def logger=(logger)
    @_logger = logger
  end

  class Logger < ::Logger
    def initialize(*args)
      super
      @formatter = Formatter.new
      @level = ::Logger::DEBUG
    end

    class Formatter < ::Logger::Formatter
    end
  end
end

# Apply default logger
logger = Envoku::Logger.new(STDOUT)
logger.progname = "envoku"
logger.level = (ENV["ENVOKU_LOG_LEVEL"] || ENV["LOG_LEVEL"] || "INFO").downcase.to_sym
Envoku.logger = logger
