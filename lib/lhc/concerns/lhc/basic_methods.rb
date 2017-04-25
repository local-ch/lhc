require 'active_support'

module LHC
  module BasicMethods
    extend ActiveSupport::Concern

    module ClassMethods
      def request(options)
        if options.is_a? Array
          parallel_requests(options)
        else
          LHC::Request.new(options).response
        end
      end

      [:get, :post, :put, :delete].each do |http_method|
        define_method(http_method) do |url, options = {}|
          request(options.merge(
                    url: url,
                    method: http_method
          ))
        end
      end

      private

      def parallel_requests(options)
        hydra = Typhoeus::Hydra.hydra
        requests = []
        options.each do |option|
          request = LHC::Request.new(option, false)
          requests << request
          hydra.queue request.raw unless request.response.present?
        end
        hydra.run
        requests.map(&:response)
      end
    end
  end
end
