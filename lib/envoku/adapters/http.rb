require 'dotenv'
require 'envoku/adapters'
require 'envoku/adapters/base'
require 'net/http'

module Envoku
  module Adapters
    class Http < Base
      def load
        Envoku.logger.debug("Downloading HTTP File: #{remote_uri.to_s}")
        download_file
      end

      private

      def remote_uri
        @uri
      end

      def download_file
        @content = http_get_content
        Envoku.logger.error("Error Downloading HTTP File: #{remote_uri.to_s}") unless @content
      end

      def http_get_content
        response = Net::HTTP.get_response(remote_uri) rescue nil
        response.body if response.is_a?(Net::HTTPSuccess)
      end
    end
  end
end
