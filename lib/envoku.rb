require "envoku/version"
require "envoku/adapters/s3"
require "envoku/rails" if defined? Rails

module Envoku

  module_function

  def load options = {}
    instance = Envoku::Adapters::S3.new options
    instance.load
  end
end
