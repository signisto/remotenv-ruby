require "uri"

module Envoku
  module Utils

    module_function

    def parsed_url
      return nil if ENV['ENVOKU_URL'] == nil || ENV['ENVOKU_URL'] == ""
      ENV['ENVOKU_URL']
    end

    def parsed_uri
      return nil unless parsed_url
      parser = ::URI::RFC2396_Parser.new
      uri = parser.parse(parsed_url)
      uri
    rescue Exception => error
      Envoku.logger.error("URI Parse Error: URL = #{parsed_url || '[not set]'}")
      Envoku.logger.error("  #{error.message}")
      (0..2).each do |index|
        Envoku.logger.error("  #{error.backtrace[index]}")
      end
      nil
    end
  end
end
