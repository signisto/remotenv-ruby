require 'cgi'
require 'dotenv'
require 'remotenv/adapters'
require 'fileutils'
require 'net/http'
require 'openssl'
require 'base64'

module Remotenv
  module Adapters
    class S3 < Http

      private

      def config
        @_config ||= begin
          uri = Remotenv.uri
          return {} unless uri && uri.host && uri.path
          {
            'filename' => uri.path[1..-1],
            'bucket_name' => uri.host,
            'access_key_id' => uri.user,
            'secret_access_key' => uri.password ? ::URI.unescape(uri.password) : nil,
          }.reject { |_, v| v.nil? }
        end
      end

      def remote_uri
         if config['access_key_id'] && config['secret_access_key']
           URI(signed_s3_url)
         else
           URI(direct_s3_url)
         end
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
