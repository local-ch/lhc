require 'rails_helper'

describe LHC do

  context 'interceptor response competition' do

    before(:each) do

      class LocalCacheInterceptor < LHC::Interceptor

        def before_request(request)
          if request.url == 'http://local.ch'
            return_response Typhoeus::Response.new(response_body: 'Im served from local cache')
          end
        end
      end

      class RemoteCacheInterceptor < LHC::Interceptor

        def before_request(request)
          if request.url == 'http://local2.ch' && request.response.nil?
            return_response Typhoeus::Response.new(response_body: 'Im served from remote cache')
          end
        end
      end

      LHC.default_interceptors = [LocalCacheInterceptor, RemoteCacheInterceptor]
    end

    it 'can handle multiple interceptors that compete for returning the response' do
      response = LHC.get('http://local.ch')
      expect(response.body).to eq 'Im served from local cache'
      response = LHC.get('http://local2.ch')
      expect(response.body).to eq 'Im served from remote cache'
    end
  end
end
