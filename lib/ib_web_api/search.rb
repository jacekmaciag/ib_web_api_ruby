module IbWebApi
  module Search

    def search(symbol, security_type: nil)

    end

    private

    def path
      "/search/#{IbWebApi::API_VERSION}/search"

    end
  end
end