require 'envoku'
require 'yaml'

namespace :envoku do

  desc "Load Envoku variables"
  task :load do
    Envoku.load
  end

  desc "Show Envoku Info"
  task :info => :load do
    puts "URL: #{Envoku.uri || '[not set]'}"
    puts "URI: #{Envoku.url.to_yaml}"
  end

  desc "List all keys"
  task :list => :load do
    Envoku.data.each do |key, value|
      puts "\e[33m#{key}\e[0m \e[90m=\e[0m #{value}"
    end
  end
end
