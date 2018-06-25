require "./utils/*"
require "./geoip/*"

require "kemal"
require "json"
require "maxminddb"
require "redis"

# 30 days in seconds
EXPIRE_TIMEOUT = 60 * 60 * 24 * 30

# TODO: Write documentation for `Geoip`
module Geoip
  # TODO: Put your code here
end

mmdb = MaxMindDB::GeoIP2.new("#{__DIR__}/../vendor/GeoLite2-City.mmdb")

add_handler CORSHandler.new
cache = Geoip::CacheIp.new(Redis.new("127.0.0.1", 6379, nil, nil, 0, ENV["REDIS_URL"]?))

get "/geocode.json" do |env|
  env.response.content_type = "application/json"

  remote_ip = env.params.query["ip"]? || env.remote_ip || "127.0.0.1"
  cache.fetch remote_ip do
    result = mmdb.lookup(remote_ip)
    value = Geoip::Result.new(remote_ip).to_json(result)
    value
  end
end

get "/" do
  "Welome on Izi Geoip service v#{Geoip::VERSION} https://hub.docker.com/r/izikaj/geoip/"
end

Kemal.run
