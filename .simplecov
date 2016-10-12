require 'codecov'
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::Codecov,
])
SimpleCov.start do
  add_filter 'spec'
end
