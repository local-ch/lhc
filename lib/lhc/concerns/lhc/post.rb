require 'active_support'

module LHC

  module Post
    extend ActiveSupport::Concern

    module ClassMethods

      def post(url, options)
        LHC::Request.new(
          options.merge(
            url: url,
            method: :post
          )
        ).response
      end
    end
  end
end
