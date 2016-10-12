require 'envoku'
require 'yaml'

namespace :envoku do

  task :load do
    Envoku.load
  end

  desc "Show Envoku Info"
  task :info => :load do
    puts "URL: #{ENV['ENVOKU_URL'] ? ENV['ENVOKU_URL'] : "[not set]"}"
  end

  desc "List Envoku Features"
  task :features => :load do
    features = Envoku::Feature.all
    puts features.to_yaml
  end
end
