require 'envoku/adapters'

module Envoku
  module Adapters
    class Base
      attr_reader :uri
      attr_reader :data
      attr_reader :options

      def initialize(uri, options = {})
        @uri = uri
        @options = options
        @data = {}
        @content = ""
      end

      def load!
        Envoku.logger.debug("Adapter: #{self.class.name}")
        before_load
        load
        after_load
        apply_environment
        set_refresh_timestamp
      end

      def before_load
      end

      def load
        raise "Envoku::Adapter::Base should not be used directly"
      end

      def after_load
      end

      def set_refresh_timestamp
        ENV['ENVOKU_REFRESHED_AT'] = Time.now.to_s
      end

      def apply_environment
        Envoku.logger.debug("Applying ENV vars")
        @data = Dotenv::Parser.call(@content)
        @data.each do |key, value|
          ENV[key] ||= value
        end
      end

      def get(key)
        @data[key]
      end
    end
  end
end
