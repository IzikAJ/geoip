require "./utils/*"
require "./geoip/*"

require "kemal"
require "json"
require "maxminddb"

# TODO: Write documentation for `Geoip`
module Geoip
  # TODO: Put your code here
end

def render_result_json(result)
  string = JSON.build do |json|
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

get "/geocode.json" do |ctx|
  result = mmdb.lookup(ctx.remote_ip || "127.0.0.1")
  render_result_json(result)
end

get "/" do
  "Welome here v#{Geoip::VERSION}"
end

Kemal.run
