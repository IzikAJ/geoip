require "./utils/*"
require "./geoip/*"

require "kemal"
require "json"
require "maxminddb"
require "redis"
redis = Redis.new("redis")
redis.set("foo", "bar")
redis.get("foo")

# 20 seconds
EXPIRE_TIMEOUT = 20 * 60

# 1 day
# EXPIRE_TIMEOUT = 60 * 60 * 24

# TODO: Write documentation for `Geoip`
module Geoip
  # TODO: Put your code here
end

def render_result_json(result)
  JSON.build do |json|
    json.object do
      json.field "continent_code", result.continent.code.to_s
      json.field "continent_name", result.continent.names.try(&.["en"]).to_s
      json.field "country_iso_code", result.country.iso_code.to_s
      json.field "country_name", result.country.names.try(&.["en"]).to_s
      json.field "location_latitude", result.location.latitude.to_s
      json.field "location_longitude", result.location.longitude.to_s
      json.field "location_time_zone", result.location.time_zone.to_s
      json.field "postal_code", result.postal.code.to_s
      json.field "version", Geoip::VERSION
    end
  end
end

mmdb = MaxMindDB::GeoIP2.new("#{__DIR__}/../vendor/GeoLite2-City.mmdb")

add_handler CORSHandler.new

get "/geocode.json" do |env|
  env.response.content_type = "application/json"

  remote_ip = env.remote_ip || "127.0.0.1"
  if chached = redis.get("geocode::#{remote_ip}")
    puts "!!! CHACHED #{remote_ip}"
    chached
  else
    puts "!!! NEW VALUE #{remote_ip}"
    result = mmdb.lookup(remote_ip)
    value = render_result_json(result)
    redis.setex("geocode::#{remote_ip}", EXPIRE_TIMEOUT, value)
    value
  end
end

get "/" do
  "Welome here v#{Geoip::VERSION}"
end

Kemal.run
