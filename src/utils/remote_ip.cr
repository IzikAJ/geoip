require "http/server"
require "ipaddress"

class HTTP::Server::Context
  CLIENT_IP_HEADERS = %w(
    CLIENT_IP
    X_REAL_IP
    X_FORWARDED_FOR
    X_CLUSTER_CLIENT_IP
    X_FORWARDED
    FORWARDED
  )

  @remote_ip : String?

  private def find_public_ip(ips = [] of String)
    ips.find do |item|
      if ip = item
        begin
          !IPAddress::IPv4.new(ip).private?
        rescue
          false
        end
      end
    end || "127.0.0.1"
  end

  private def fetch_all_ip_headers(headers)
    CLIENT_IP_HEADERS.map do |header|
      dashed_header = header.tr("_", "-")
      [
        headers[header]?,
        headers[dashed_header]?,
        headers["HTTP_#{header}"]?,
        headers["Http-#{dashed_header}"]?,
      ]
    end.flatten
       .map(&.try(&.strip))
       .select { |ip| ip && ip.size > 0 }
       .uniq
  end

  def remote_ip
    if headers = request.headers
      @remote_ip ||= find_public_ip(fetch_all_ip_headers(headers))
    end
  end
end
