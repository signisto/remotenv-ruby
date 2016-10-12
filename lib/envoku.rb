require "envoku/version"
require "envoku/adapters/s3"
require "envoku/feature"
require "envoku/rails" if defined?(Rails)

module Envoku

  module_function

  def load(options = {})
    instance = Envoku::Adapters::S3.new options
    instance.load
  end

  def feature_enabled_for?(feature_name, resource)
    Envoku::Feature.new(feature_name).enabled_for?(resource)
  end
end
