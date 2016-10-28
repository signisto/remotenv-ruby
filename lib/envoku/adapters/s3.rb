require 'dotenv'
require 'envoku/adapters'
require 'fileutils'
require 'net/http'
require 'ostruct'
require 'securerandom'
require 'base64'

module Envoku
  module Adapters
    class S3

      attr_reader :options

      def initialize(custom_options = {})
        default_options = {
          filename: nil,
          bucket_name: nil,
          access_key_id: nil,
          secret_access_key: nil,
        }
        @options = OpenStruct.new default_options.merge(custom_options)
        @local_file_name = "/tmp/envoku-#{SecureRandom.hex 16}.env"
        @data = {}
      end

      def load
        Envoku.logger.debug("Loading via S3 Adapter")
        apply_environment_options
        return unless options.bucket_name && options.filename && options.access_key_id && options.secret_access_key
        Envoku.logger.debug("Downloading \"#{options.bucket_name}/#{options.filename}\" from S3")
        FileUtils.rm @local_file_name if File.exists? @local_file_name
        return unless clone_s3_file
        @_env_before = ENV.to_h
        Envoku.logger.debug("Applying ENV vars from S3")
        @data = Dotenv.overload(@local_file_name) || {}
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
        FileUtils.rm @local_file_name
        ENV['ENVOKU_REFRESHED_AT'] = Time.now.to_s
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

      def clone_s3_file
        s3_direct_url = "https://#{options.bucket_name}.s3.amazonaws.com/#{options.filename}"
        s3_resource = "/#{options.bucket_name}/#{options.filename}"
        s3_expires_at = Time.now + 300
        signature_payload = "GET\n\n\n#{s3_expires_at.to_i}\n#{s3_resource}"
        digest = OpenSSL::Digest.new 'sha1'
        hmac = OpenSSL::HMAC.digest digest, options.secret_access_key, signature_payload
        query_params = [
          "AWSAccessKeyId=#{options.access_key_id}",
          "Expires=#{s3_expires_at.to_i}",
          "Signature=#{CGI.escape Base64.encode64(hmac).strip}"
        ]
        s3_signed_uri = ::URI.parse "#{s3_direct_url}?#{query_params.join('&')}"
        s3_response = Net::HTTP.get_response s3_signed_uri
        if s3_response.is_a? Net::HTTPSuccess
          File.write @local_file_name, s3_response.body
        end
      end

      def apply_environment_options
        if Envoku::URL
          return nil unless Envoku::URI && Envoku::URI.host && Envoku::URI.path && Envoku::URI.user && Envoku::URI.password
          @options.filename ||= Envoku::URI.path[1..-1]
          @options.bucket_name ||= Envoku::URI.host
          @options.access_key_id ||= Envoku::URI.user
          @options.secret_access_key ||= ::URI.unescape(Envoku::URI.password)
        else
          @options.filename ||= ENV['ENVOKU_FILENAME']
          @options.bucket_name ||= ENV['ENVOKU_BUCKET']
          @options.access_key_id ||= ENV['ENVOKU_ACCESS_KEY_ID'] || ENV['AWS_ACCESS_KEY_ID']
          @options.secret_access_key ||= ENV['ENVOKU_SECRET_ACCESS_KEY'] || ENV['AWS_SECRET_ACCESS_KEY']
        end
      end
    end
  end
end
