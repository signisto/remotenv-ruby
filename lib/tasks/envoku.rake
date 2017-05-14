require 'envoku'
require 'yaml'

namespace :envoku do

  desc "Load Envoku variables"
  task :load do
    Envoku.load
  end

  desc "Show Envoku Info"
  task :info => :load do
    puts "URL: #{Envoku::URL || '[not set]'}"
    puts "URI: #{Envoku::URI.to_yaml}"
  end

  desc "List Envoku Features"
  task :features => :load do
    features = Envoku::Feature.all
    puts features.to_yaml
  end

  desc "List all keys"
  task :list => :load do
    data = Envoku.get_all
    data.each do |key, value|
      puts "\e[33m#{key}\e[0m \e[90m=\e[0m #{value}"
    end
  end
end
