require "codeclimate-test-reporter"
require 'codecov'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
  (CodeClimate::TestReporter::Formatter if ENV['CODECLIMATE_REPO_TOKEN']),
  (SimpleCov::Formatter::Codecov if ENV['CODECOV_TOKEN']),
  SimpleCov::Formatter::HTMLFormatter,
].compact)
SimpleCov.start do
  add_filter "spec"
  add_group "Adapters", "lib/envoku/adapters/"
end
