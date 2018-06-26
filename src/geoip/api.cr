require "json"
require "maxminddb"
require "redis"

module Geoip
  class Api
    property mmdb : MaxMindDB::GeoIP2
    property redis : Redis
    property cache : Geoip::CacheIp
    property updates : Modificator

    def initialize
      @mmdb = MaxMindDB::GeoIP2.new("#{Geoip::App.root}/vendor/GeoLite2-Country.mmdb")
      @redis = Redis.new("127.0.0.1", 6379, nil, nil, 0, ENV["REDIS_URL"]?)
      @cache = Geoip::CacheIp.new(@redis)

      cache.clear
      @updates = Modificator.new("eu-countries", redis)

      add_handler CORSHandler.new
      draw_routes
    end

    def draw_routes
      get "/geocode.json" do |env|
        as_json! env
        remote_ip = env.params.query["ip"]? || env.remote_ip || "127.0.0.1"

        cache.fetch remote_ip do
          fetch_geodata(remote_ip).to_h
        end
      end
    end

    protected def as_json!(env)
      env.response.content_type = "application/json"
    end

    private def fetch_geodata(remote_ip : String)
      begin
        lookup = mmdb.lookup(remote_ip)
        updates.modify(Geoip::Result.as_json(remote_ip, lookup))
      rescue ex
        {
          ip:      remote_ip,
          error:   "invalid",
          message: ex.message,
        }.to_h
      end
    end
  end
end
