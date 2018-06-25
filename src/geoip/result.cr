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
  end
end
