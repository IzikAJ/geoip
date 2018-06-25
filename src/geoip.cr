require "./utils/*"
require "./geoip/*"
require "kemal"

module Geoip
  class App
    def initialize
      Api.new
      draw_public_routes!
    end

    def draw_public_routes!
      get "/" do |env|
        render "src/views/welcome.ecr"
      end

      error 404 do
        @error_code = 404
        render "src/views/error.ecr"
      end
    end

    def run
      Kemal.run
    end

    def self.run
      self.new.run
    end

    def self.root
      "#{__DIR__}/.."
    end
  end
end

Geoip::App.run
