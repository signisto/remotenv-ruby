require 'remotenv/adapters'

module Remotenv
  module Adapters
    class Base
      attr_reader :uri
      attr_reader :data
      attr_reader :options

      def initialize(uri, options = {})
        @uri = uri
        @options = options
        @data = {}
        @content = nil
      end

      def load!
        Remotenv.logger.debug("Adapter: #{self.class.name}")
        before_load
        load
        after_load
        apply_environment
        set_refresh_timestamp
      end

      def before_load
      end

      def load
        raise "Remotenv::Adapter::Base should not be used directly"
      end

      def after_load
      end

      def set_refresh_timestamp
        ENV['REMOTENV_REFRESHED_AT'] = Time.now.to_s
      end

      def apply_environment
        Remotenv.logger.debug("Applying environment variables")
        @data = Dotenv::Parser.call(@content)
        Remotenv.logger.debug("ENV: #{@data.keys.join(', ')}")
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
