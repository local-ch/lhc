require 'active_support'

module LHC

  module Get
    extend ActiveSupport::Concern

    module ClassMethods

      def get(url, options = {})
        LHC::Request.new(
          options.merge(
            url: url,
            method: :get
          )
        ).response
      end
    end
  end
end
