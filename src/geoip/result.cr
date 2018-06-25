module Geoip
  class Result
    def self.as_json(ip : String, result)
      {
        "ip"                 => ip,
        "continent_code"     => result.continent.code.to_s,
        "continent_name"     => result.continent.names.try(&.["en"]).to_s,
        "country_code"       => result.country.iso_code.to_s,
        "country_name"       => result.country.names.try(&.["en"]).to_s,
        "location_latitude"  => result.location.latitude.to_s,
        "location_longitude" => result.location.longitude.to_s,
        "location_time_zone" => result.location.time_zone.to_s,
        "postal_code"        => result.postal.code.to_s,
        "version"            => Geoip::VERSION,
      }.to_h
    end

    def self.to_json(ip : String, result)
      JSON.build do |json|
        if data = result
          json.object do
            json.field "ip", ip
            json.field "continent_code", data.continent.code.to_s
            json.field "continent_name", data.continent.names.try(&.["en"]).to_s
            json.field "country_code", data.country.iso_code.to_s
            json.field "country_name", data.country.names.try(&.["en"]).to_s
            json.field "location_latitude", data.location.latitude.to_s
            json.field "location_longitude", data.location.longitude.to_s
            json.field "location_time_zone", data.location.time_zone.to_s
            json.field "postal_code", data.postal.code.to_s
            json.field "version", Geoip::VERSION
          end
        else
          json.object do
            json.field "error", "some error"
          end
        end
      end
    end
  end
end
