require "redis"

module Geoip
  class CacheIp
    # 30 days in seconds
    EXPIRE_TIMEOUT = 60 * 60 * 24 * 30
    PREFIX         = "geocode_"

    def initialize(@redis : Redis)
      @redis ||= Redis.new
    end

    def fetch(ip : String)
      if chached = @redis.get("#{PREFIX}#{ip}")
        chached
      else
        value = yield
        @redis.setex("#{PREFIX}#{ip}", EXPIRE_TIMEOUT, value)
        value
      end
    end
  end
end
