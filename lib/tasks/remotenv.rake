require 'remotenv'
require 'yaml'

namespace :remotenv do

  desc "Load Remotenv variables"
  task :load do
    Remotenv.load
  end

  desc "Show Remotenv Info"
  task :info => :load do
    puts "URL: #{Remotenv.uri || '[not set]'}"
    puts "URI: #{Remotenv.url.to_yaml}"
  end

  desc "List all keys"
  task :list => :load do
    Remotenv.data.each do |key, value|
      puts "\e[33m#{key}\e[0m \e[90m=\e[0m #{value}"
    end
  end
end
