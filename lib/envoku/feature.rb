module Envoku
  class Feature
    ENV_NAMESPACE = "ENVOKU_FEATURE_"

    attr_reader :name
    attr_reader :description

    def self.all
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
      Envoku.redis.sismember("envoku:features:#{@name}:#{resource.class.name}", "#{resource.id}")
    end

    def enable_for!(resource)
      Envoku.redis.multi do
        Envoku.redis.sadd("envoku:features:#{@name}:#{resource.class.name}", resource.id.to_s)
        Envoku.redis.sadd("envoku:features:#{resource.class.name}:#{resource.id}", @name)
      end
    end

    def disable_for!(resource)
      Envoku.redis.multi do
        Envoku.redis.del("envoku:features:#{@name}:#{resource.class.name}")
        Envoku.redis.del("envoku:features:#{resource.class.name}:#{resource.id}")
      end
    end

    def toggle_for!(resource)
      enabled_for?(resource) ? disable_for!(resource) : enable_for!(resource)
    end

    def resources
      list = []
      feature_prefix = "envoku:features:#{@name}"
      klasses = Envoku.redis.keys("#{feature_prefix}:*").map { |klass| klass[(feature_prefix.length + 1)..-1] }
      klasses.each do |klass|
        ids = Envoku.redis.smembers("#{feature_prefix}:#{klass}")
        ids.each do |id|
          list.push("#{klass}:#{id}")
        end
      end
      list
    end
  end
end
