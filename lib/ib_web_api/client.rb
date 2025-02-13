module IbWebApi
  class Client
    def initialize
      @host = IbWebApi::HOST
      @api_version = IbWebApi::API_VERSION
    end

    def request(method, path, params = {})
      uri = URI("https://#{@host}#{path}")
      uri.query = URI.encode_www_form(params)
      req = Net::HTTP::Get.new(uri)
      ssl_socket.puts(req)
      response
    end

    def ssl_socket
      OpenSSL::SSL::SSLSocket.open(@host, 443) do |socket|
        socket.sync_close = true
      end.connect
    end

    def response
      buffer = []

      while (line = ssl_socket.gets)
        break if line.strip.empty?

        buffer << line
      end

      buffer.join.strip
    end
  end
end