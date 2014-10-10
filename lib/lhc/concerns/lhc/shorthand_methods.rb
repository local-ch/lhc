require 'active_support'

module LHC

  module ShorthandMethods
    extend ActiveSupport::Concern

    module ClassMethods

      def set(name, endpoint, options = {})
        LHC::Config.set(name, endpoint, options)
      end

      def get(url, options = {})
        request(options.merge(
          url: url,
          method: :get
        ))
      end

      def post(url, options)
        request(options.merge(
          url: url,
          method: :post
        ))
      end

      def put(url, options)
        request(options.merge(
          url: url,
          method: :put
        ))
      end

      def delete(url, options = {})
        request(options.merge(
          url: url,
          method: :delete
        ))
      end

      def request(options)
        LHC::Request.new(options).response
      end
    end
  end
end
