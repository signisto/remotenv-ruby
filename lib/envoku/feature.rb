module Envoku
  class Feature
    ENV_NAMESPACE = "ENVOKU_FEATURE_"

    attr_reader :name
    attr_reader :description
    # attr_reader :expires_at # when the feature will dissappear
    # attr_reader :available_at # when the feature unlocks

    def self.all(filter = {})
      # TODO: Implement filters
      keys = ENV.select { |key, value| key.index(ENV_NAMESPACE) == 0 }
      keys.keys.map do |key|
        Feature.new(key[(ENV_NAMESPACE.length)..-1])
      end
    end

    def initialize(name)
      @name = name
      var_string = ENV["#{ENV_NAMESPACE}#{name}"]
      return nil unless var_string
      attributes = YAML.safe_load(var_string)
      attributes.each do |key, value|
        instance_variable_set(:"@#{key}", value)
      end
      @enabled = !!@enabled
    end

    def enabled?
      @enabled
    end

    def enabled_for?(resource)
      return true if enabled?
      # TODO: Implement via Redis
    end

    def enable_for!(resource)
      # TODO: Implement via Redis
    end
  end
end
