require 'dotenv'
require 'envoku/adapters'
require 'envoku/adapters/base'
require 'fileutils'
require 'net/http'

module Envoku
  module Adapters
    class Http < Base
      def remote_url
        @uri.to_s
      end

      def local_path
        "/tmp/envoku.env"
      end

      def before_load
        FileUtils.rm(local_path) if File.exist?(local_path)
      end

      def load
        Envoku.logger.debug("Downloading \"#{remote_url}\"")
        download_file
      end

      def after_load
        FileUtils.rm(local_path) if File.exist?(local_path)
      end

      private

      def download_file
        remote_uri = URI(remote_url)
        response = Net::HTTP.get_response(remote_uri)
        if response.is_a?(Net::HTTPSuccess)
          @content = response.body
          File.write(local_path, response.body)
          true
        else
          Envoku.logger.debug("could not get file #{sresponse.to_yaml}")
          false
        end
      end
    end
  end
end
