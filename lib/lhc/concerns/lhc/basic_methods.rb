require 'active_support'

module LHC

  module BasicMethods
    extend ActiveSupport::Concern

    module ClassMethods

      def request(options)
        LHC::Request.new(options).response
      end

      [:get, :post, :put, :delete].each do |http_method|
        define_method(http_method) do |url, options = {}|
          request(options.merge(
            url: url,
            method: http_method
          ))
        end
      end
    end

  end

end
