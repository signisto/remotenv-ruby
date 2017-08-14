require "uri"

module Remotenv
  module Utils

    module_function

    def parsed_url
      return nil if ENV['REMOTENV_URL'] == nil || ENV['REMOTENV_URL'] == ""
      ENV['REMOTENV_URL']
    end

    def parsed_uri
      return nil unless parsed_url
      parser = ::URI::RFC2396_Parser.new
      uri = parser.parse(parsed_url)
      uri
    rescue StandardError => error
      Remotenv.logger.error("URI Parse Error: URL = #{parsed_url || '[not set]'}")
      Remotenv.logger.error("  #{error.message}")
      (0..2).each do |index|
        Remotenv.logger.error("  #{error.backtrace[index]}")
      end
      nil
    end
  end
end
