require 'dotenv'
require 'envoku/adapters'
require 'fileutils'
require 'net/http'
require 'openssl'
require 'base64'

module Envoku
  module Adapters
    class S3 < Http
      def config
        @_config ||= begin
          return {} unless Envoku::URI && Envoku::URI.host && Envoku::URI.path && Envoku::URI.user && Envoku::URI.password
          {
            'filename' => Envoku::URI.path[1..-1],
            'bucket_name' => Envoku::URI.host,
            'access_key_id' => Envoku::URI.user,
            'secret_access_key' => ::URI.unescape(Envoku::URI.password),
          }
        end
      end

      def remote_url
        return direct_s3_url unless (config['access_key_id'] && config['secret_access_key'])
        signed_s3_url
      end

      def direct_s3_url
        "https://#{config['bucket_name']}.s3.amazonaws.com/#{config['filename']}"
      end

      def signed_s3_url
        s3_resource = "/#{config['bucket_name']}/#{config['filename']}"
        s3_expires_at = Time.now + 300
        signature_payload = "GET\n\n\n#{s3_expires_at.to_i}\n#{s3_resource}"
        digest = OpenSSL::Digest.new('sha1')
        hmac = OpenSSL::HMAC.digest(digest, config['secret_access_key'], signature_payload)
        query_params = [
          "AWSAccessKeyId=#{config['access_key_id']}",
          "Expires=#{s3_expires_at.to_i}",
          "Signature=#{CGI.escape Base64.encode64(hmac).strip}"
        ]
        "#{direct_s3_url}?#{query_params.join('&')}"
      end
    end
  end
end
