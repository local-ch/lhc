require 'rails_helper'

describe LHC do

  context 'interceptor' do

    before(:each) do
      class TrackingIdInterceptor < LHC::Interceptor

        def before_request(request)
          request.merge_params!(tid: 123)
        end
      end
      LHC.config.interceptors = [TrackingIdInterceptor]
    end

    it 'can modify requests before they are send' do
      stub_request(:get, "http://local.ch/?tid=123")
      LHC.get('http://local.ch')
    end
  end
end
