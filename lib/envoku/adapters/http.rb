require 'dotenv'
require 'envoku/adapters'
require 'envoku/adapters/base'
require 'net/http'

module Envoku
  module Adapters
    class Http < Base
      def remote_url
        @uri.to_s
      end

      def load
        Envoku.logger.debug("Downloading HTTP File: #{remote_url}")
        download_file
      end

      private

      def download_file
        remote_uri = URI(remote_url)
        response = Net::HTTP.get_response(remote_uri) rescue nil
        if response.is_a?(Net::HTTPSuccess)
          @content = response.body
          true
        else
          Envoku.logger.error("Error Downloading HTTP File: #{remote_url}")
          false
        end
      end
    end
  end
end
