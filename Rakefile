require "bundler/gem_tasks"
require "rspec/core/rake_task"

load "#{__dir__}/lib/tasks/remotenv.rake"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec
