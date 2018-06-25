require "redis"
require "yaml"

module Geoip
  class Modificator
    getter filename : String
    getter redis : Redis
    getter modifications : Array(String)

    private def redis_version_key
      "modify_version-#{filename}"
    end

    private def redis_modifications_key
      "modify_sets-#{filename}"
    end

    def initialize(@filename : String, @redis : Redis)
      version = redis.get(redis_version_key) || 0
      load_modifications_if_required(version.to_i64)
      @modifications = [] of String
      fetch_modifications
    end

    def modify(result)
      modifications.each do |key|
        result[key] = is?(result, key).to_s
      end
      result
    end

    private def is?(result, key, found_by = "country_code")
      redis.sismember(key, result[found_by]) == 1_i64
    end

    # strategy: add | replace
    private def update_modification_sets(sets, data, strategy = "add")
      sets.each do |set_name|
        redis.del set_name if strategy == "replace"
        redis.sadd redis_modifications_key, set_name if data[set_name].try(&.size) > 0

        data[set_name].each do |val|
          redis.sadd set_name, val
        end
      end
    end

    private def fetch_modifications
      @modifications = redis.smembers(redis_modifications_key).map { |item| item.to_s } || [] of String
    end

    private def load_modifications_if_required(version : Int64)
      yaml = File.open("#{Geoip::App.root}/vendor/#{filename}.yml") do |file|
        YAML.parse(file)
      end

      # fetch version from yaml
      y_version = yaml["version"].as_i64? || 0
      strategy = yaml["strategy"]? || "add"

      # if version requires merge
      if y_version > version
        set_names = yaml.as_h.keys - ["strategy", "version"]
        update_modification_sets(set_names, yaml, strategy.to_s)
        puts "#{filename}: UPDATE #{version} >> #{y_version}"
        redis.set redis_version_key, y_version
        puts "#{filename}: UPDATED #{set_names}"
      else
        puts "#{filename}: ALREADY UP TO DATE #{version}"
      end
    end
  end
end
