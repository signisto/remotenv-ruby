require 'dotenv'
require 'remotenv/adapters'
require 'remotenv/adapters/base'
require 'net/http'

module Remotenv
  module Adapters
    class Http < Base
      def load
        Remotenv.logger.debug("Downloading HTTP File: #{remote_uri}")
        download_file
      end

      private

      def remote_uri
        @uri
      end

      def download_file
        @content = http_get_content
        Remotenv.logger.error("Error Downloading HTTP File: #{remote_uri}") unless @content
      end

      def http_get_content
        response = Net::HTTP.get_response(remote_uri) rescue nil
        response.body if response.is_a?(Net::HTTPSuccess)
      end
    end
  end
end
