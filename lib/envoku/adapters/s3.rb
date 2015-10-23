require 'dotenv'
require 'net/http'

module Envoku
  module Adapters
    class S3
      def initialize options = {}
        @options = options
      end

      def load!
        Dotenv.load
        @local_file_name = "/tmp/envoku-#{credentials.bucket_name}.env"
        clone_s3_file
        Dotenv.load! @local_file_name
        ENV['ENVOKU_REFRESHED_AT'] = DateTime.now.to_i.to_s
      end

      def clone_s3_file
        s3_file_name = @options[:filename] || ENV['ENVOKU_FILENAME'] || "#{Rails.env}.env"
        s3_direct_url = "https://#{credentials.bucket_name}.s3.amazonaws.com/#{s3_file_name}"
        s3_resource = "/#{credentials.bucket_name}/#{s3_file_name}"
        s3_expires_at = DateTime.now + 5.minutes
        signature_payload = "GET\n\n\n#{s3_expires_at.to_i}\n#{s3_resource}"
        digest = OpenSSL::Digest.new 'sha1'
        hmac = OpenSSL::HMAC.digest digest, credentials.secret_access_key, signature_payload
        query_params = [
          "AWSAccessKeyId=#{credentials.access_key_id}",
          "Expires=#{s3_expires_at.to_i}",
          "Signature=#{CGI.escape Base64.encode64(hmac).strip}"
        ]
        s3_signed_uri = URI.parse "#{s3_direct_url}?#{query_params.join('&')}"
        s3_response = Net::HTTP.get_response s3_signed_uri
        if s3_response.is_a? Net::HTTPSuccess
          File.write @local_file_name, s3_response.body
        else
          raise "Could not load environment file from S3:\n#{s3_response.body}"
        end
      end

      def credentials
        @credentials ||= begin
          _ = OpenStruct.new(
            bucket_name: @options[:bucket] || ENV['ENVOKU_BUCKET'],
            access_key_id: @options[:access_key_id] || ENV['ENVOKU_ACCESS_KEY_ID'] || ENV['AWS_ACCESS_KEY_ID'],
            secret_access_key: @options[:secret_access_key] || ENV['ENVOKU_SECRET_ACCESS_KEY'] || ENV['AWS_SECRET_ACCESS_KEY'],
          )
          raise "Credntials not supplied" unless _.to_h.keys.all? { |k| _.send(k).present? }
          _
        end
      end
    end
  end
end
