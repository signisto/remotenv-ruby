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

      def initialize custom_options = {}
        default_options = {
          filename: nil,
          bucket_name: nil,
          access_key_id: nil,
          secret_access_key: nil,
        }
        @options = OpenStruct.new default_options.merge(custom_options)
        @local_file_name = "/tmp/envoku-#{SecureRandom.hex 16}.env"
      end

      def load
        Dotenv.load
        apply_environment_options
        return unless options.bucket_name && options.filename && options.access_key_id && options.secret_access_key
        FileUtils.rm @local_file_name if File.exists? @local_file_name
        return unless clone_s3_file
        Dotenv.overload(@local_file_name)
        FileUtils.rm @local_file_name
        ENV['ENVOKU_REFRESHED_AT'] = Time.now.to_s
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
        s3_signed_uri = URI.parse "#{s3_direct_url}?#{query_params.join('&')}"
        s3_response = Net::HTTP.get_response s3_signed_uri
        if s3_response.is_a? Net::HTTPSuccess
          File.write @local_file_name, s3_response.body
        end
      end

      def apply_environment_options
        if ENV['ENVOKU_URL']
          envoku_uri = URI.parse(ENV['ENVOKU_URL'])
          return nil unless envoku_uri.host && envoku_uri.path && envoku_uri.user && envoku_uri.password
          @options.filename ||= envoku_uri.path[1..-1]
          @options.bucket_name ||= envoku_uri.host
          @options.access_key_id ||= envoku_uri.user
          @options.secret_access_key ||= envoku_uri.password
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
