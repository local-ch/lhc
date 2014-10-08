require 'active_support'

module LHC

  module Delete
    extend ActiveSupport::Concern

    module ClassMethods

      def delete(url, options = {})
        LHC::Request.new(
          options.merge(
            url: url,
            method: :delete
          )
        ).response
      end
    end
  end
end
