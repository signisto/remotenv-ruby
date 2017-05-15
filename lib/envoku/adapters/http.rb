require 'dotenv'
require 'envoku/adapters'
require 'envoku/adapters/base'
require 'net/http'

module Envoku
  module Adapters
    class Http < Base
      def load
        Envoku.logger.debug("Downloading HTTP File: #{remote_url}")
        download_file
      end

      private

      def remote_url
        @uri.to_s
      end

      def download_file
        @content = http_get_content
        Envoku.logger.error("Error Downloading HTTP File: #{remote_url}") unless @content
      end

      def http_get_content
        remote_uri = URI(remote_url)
        response = Net::HTTP.get_response(remote_uri) rescue nil
        response.body if response.is_a?(Net::HTTPSuccess)
      end
    end
  end
end
