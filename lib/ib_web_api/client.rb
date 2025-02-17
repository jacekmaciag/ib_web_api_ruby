require 'uri'
require 'net/http'
require 'openssl'
require 'faraday'
require 'jwt'

module IbWebApi
  class Client
    def initialize
      @host = IbWebApi::IB_HOST
      @account_id = ENV['IB_ACCOUNT_ID']
      @api_version = IbWebApi::IB_API_VERSION
      @username = ENV['IB_USERNAME']
      @password = ENV['IB_PASSWORD']
    end

    def request(path, params = {})

      uri = URI("https://#{@host}")
      # uri.path = path
      # uri.path = "/iserver/account/#{@account_id}/summary"
      uri.path = "/oauth2/api/v1/token"
      # uri.query = URI.encode_www_form(params)
      # http = Net::HTTP.new(uri.host, uri.port)
      # http.use_ssl = true

      connection = Faraday.new(url: uri.to_s)
      response = connection.post do |request|
        request.headers['Content-Type'] = 'application/x-www-form-urlencoded'
        request.body = URI.encode_www_form(
          {
            grant_type: 'client_credentials',
            client_assertion_type: "urn:ietf:params:oauth:client-assertion-type:jwt-bearer",
            client_assertion: jwt,
            scope: 'accounts.read'
          }
        )
      end

      pp response
    end

    def jwt
      private_key = OpenSSL::PKey::RSA.new(File.read("private_key.pem"))
      payload = {
        iss: @account_id,
        sub: @account_id,
        aud: "https://api.ibkr.com/oauth2/api/v1/token",
        iat: Time.now.to_i,
        exp: Time.now.to_i + (100 * 60)
      }

      JWT.encode(payload, private_key, 'RS256')
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