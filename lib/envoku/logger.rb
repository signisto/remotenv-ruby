require "logger"

module Envoku
  class Logger < ::Logger
    def initialize(*args)
      super
      @formatter = Formatter.new
      @level = ::Logger::DEBUG
    end

    class Formatter < ::Logger::Formatter
      # Default: "%s, [%s#%d] %5s -- %s: %s\n"
      Format = "%s, [%s#%d] %5s -- %s: [ENVOKU] %s\n"

      def call(severity, time, progname, msg)
        Format % [severity[0..0], format_datetime(time), $$, severity, progname, msg2str(msg)]
      end
    end
  end
end

# Apply default logger
logger = Envoku::Logger.new(STDOUT)
Envoku.logger = logger
