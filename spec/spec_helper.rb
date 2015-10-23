$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'envoku'

RSpec.configure do |config|

  config.before :each do
    ENV.keys.each { |k| ENV.delete k }
  end

end
