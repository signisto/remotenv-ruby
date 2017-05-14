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
        return unless download_file
        @_env_before = ENV.to_h
        Envoku.logger.debug("Applying ENV vars")
        @data = Dotenv.load(local_path) || {}
        @_env_after = ENV.to_h
        # TODO: Abstract the env diff to adapter base
        @_env_after.each do |key, value|
          if !@_env_before.has_key?(key)
            Envoku.logger.debug("- ADD #{key}")
            # @data[key] = value
          elsif @_env_before[key] != value
            Envoku.logger.debug("- MOD #{key}")
            # @data[key] = value
          end
        end
      end

      def after_load
        FileUtils.rm(local_path) if File.exist?(local_path)
      end

      def get_all
        @data
      end

      def get(key)
        @data[key]
      end

      def set(key, value)
        # TODO: Not yet implemented
        @data[key] = value
      end

      private

      def download_file
        remote_uri = URI(remote_url)
        response = Net::HTTP.get_response(remote_uri)
        if response.is_a?(Net::HTTPSuccess)
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
