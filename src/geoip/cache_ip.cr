require "redis"

module Geoip
  class CacheIp
    # 30 days in seconds
    EXPIRE_TIMEOUT = 60 * 60 * 24 * 30
    PREFIX         = "geocode_"

    def initialize(@redis : Redis)
      @redis ||= Redis.new
    end

    def clear
      cursor, found_keys = @redis.scan(0, "geocode_*")
      if keys = found_keys.as(Array(Redis::RedisValue))
        keys.each do |key|
          @redis.del key.as(String)
        end
      end
    end

    def fetch(ip : String)
      if chached = @redis.get("#{PREFIX}#{ip}")
        chached
      else
        value = yield.to_json
        @redis.setex("#{PREFIX}#{ip}", EXPIRE_TIMEOUT, value)
        value
      end
    end
  end
end
