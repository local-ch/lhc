require 'active_support'

module LHC

  module Put
    extend ActiveSupport::Concern

    module ClassMethods

      def put(url, options)
        LHC::Request.new(
          options.merge(
            url: url,
            method: :put
          )
        ).response
      end
    end
  end
end
