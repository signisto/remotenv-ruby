# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'envoku/version'

Gem::Specification.new do |spec|
  spec.name          = "envoku"
  spec.version       = Envoku::VERSION
  spec.authors       = ["Marc Qualie"]
  spec.email         = ["marc@marcqualie.com"]
  spec.licenses      = ['MIT']

  spec.summary       = "Store environment variables securely on S3 away from your application"
  spec.homepage      = "https://envoku.com"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "dotenv", "~> 2.2"

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "codecov", "~> 0.1.10"
  spec.add_development_dependency "codeclimate-test-reporter", "~> 1.0"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "rspec", "~> 3.6"
end
