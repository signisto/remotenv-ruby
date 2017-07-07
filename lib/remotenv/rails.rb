require "remotenv"

module Remotenv
  # Remotenv Railtie for using Remotenv to load environment before application is loaded
  class Railtie < Rails::Railtie
    config.before_configuration { load }

    # Public: Load Remotenv
    #
    # This will get called during the `before_configuration` callback, but you
    # can manually call `Remotenv::Railtie.load` if you needed it sooner.
    def load
      Remotenv.load
    end

    # Rails uses `#method_missing` to delegate all class methods to the
    # instance, which means `Kernel#load` gets called here. We don't want that.
    def self.load
      instance.load
    end

    # Rake tasks
    rake_tasks do
      Rails::Railtie.instance_method(:load).bind(self).call("tasks/remotenv.rake")
    end
  end
end
