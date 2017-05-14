require 'envoku/adapters'

module Envoku
  module Adapters
    class Base
      attr_reader :uri
      attr_reader :options

      def initialize(uri, options = {})
        @uri = uri
        @options = options
        @data = {}
      end

      # TODO: This needs to be triggered
      def before_load
      end

      def load
        raise "Envoku::Adapter::Base should not be used directly"
      end

      # TODO: This needs to be triggered
      def after_load
        ENV['ENVOKU_REFRESHED_AT'] = Time.now.to_s
      end

      def get_all
        @data
      end

      def get(key)
        @data[key]
      end

      def set(key, value)
        @data[key] = value
      end
    end
  end
end
