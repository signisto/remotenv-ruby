require "envoku"

module Envoku
  # Envoku Railtie for using Envoku to load environment before application is loaded
  class Railtie < Rails::Railtie
    config.before_configuration { load }

    # Public: Load Envoku
    #
    # This will get called during the `before_configuration` callback, but you
    # can manually call `Envoku::Railtie.load` if you needed it sooner.
    def load
      Envoku.load
    end

    # Rails uses `#method_missing` to delegate all class methods to the
    # instance, which means `Kernel#load` gets called here. We don't want that.
    def self.load
      instance.load
    end
  end
end
