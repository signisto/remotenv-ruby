require 'yaml'

module Envoku
  class Feature
    ENV_NAMESPACE = "ENVOKU_FEATURE_"
    REDIS_NAMESPACE = "envoku:features:"

    attr_reader :name
    attr_reader :description
    attr_reader :attributes

    def self.all
      keys = ENV.select { |key, value| key.index(ENV_NAMESPACE) == 0 }
      keys.keys.map do |key|
        Feature.new(key[(ENV_NAMESPACE.length)..-1])
      end
    end

    def initialize(name)
      @name = name
      @enabled = false
      @attributes = {}
      @description = nil
      var_string = ENV["#{ENV_NAMESPACE}#{name}"]
      return nil unless var_string
      @attributes = ::YAML.safe_load(var_string) rescue {}
      @description = @attributes['description']
      @enabled = !!@attributes['enabled']
      @attributes.delete('description')
      @attributes.delete('enabled')
    end

    def enabled?
      @enabled
    end

    def enabled_for?(resource)
      return true if enabled?
      Envoku.redis.sismember("#{REDIS_NAMESPACE}#{@name}:#{resource.class.name}", "#{resource.id}")
    end

    def enable_for!(resource)
      Envoku.logger.warn("feature #{name} is not permitted for #{resource.class.name}") unless permitted_for?(resource.class.name)
      Envoku.redis.multi do
        Envoku.redis.sadd("#{REDIS_NAMESPACE}#{@name}:#{resource.class.name}", resource.id.to_s)
        Envoku.redis.sadd("#{REDIS_NAMESPACE}#{resource.class.name}:#{resource.id}", @name)
      end
    end

    def disable_for!(resource)
      Envoku.logger.warn("feature #{name} is not permitted for #{resource.class.name}") unless permitted_for?(resource.class.name)
      Envoku.redis.multi do
        Envoku.redis.del("#{REDIS_NAMESPACE}#{@name}:#{resource.class.name}")
        Envoku.redis.del("#{REDIS_NAMESPACE}#{resource.class.name}:#{resource.id}")
      end
    end

    def toggle_for!(resource)
      enabled_for?(resource) ? disable_for!(resource) : enable_for!(resource)
    end

    def permitted_for?(resource_klass)
      return true unless @attributes.has_key?('permitted_resources')
      resource_klass = resource_klass.class.name unless resource_klass.is_a?(String)
      @attributes['permitted_resources'].split(',').include?(resource_klass)
    end

    def resources
      list = []
      feature_prefix = "#{REDIS_NAMESPACE}#{@name}"
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
