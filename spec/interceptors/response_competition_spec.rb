require 'rails_helper'

describe LHC do

  context 'interceptor response competition' do

    before(:each) do

      class LocalCacheInterceptor < LHC::Interceptor
        @@cached = false
        cattr_accessor :cached

        def before_request(request)
          if @@cached
            return LHC::Response.new(Typhoeus::Response.new(response_body: 'Im served from local cache'), nil)
          end
        end
      end

      class RemoteCacheInterceptor < LHC::Interceptor

        def before_request(request)
          if request.response.nil?
            return LHC::Response.new(Typhoeus::Response.new(response_body: 'Im served from remote cache'), nil)
          end
        end
      end

      LHC.configure { |c| c.interceptors = [LocalCacheInterceptor, RemoteCacheInterceptor] }
    end

    it 'can handle multiple interceptors that compete for returning the response' do
      response = LHC.get('http://local.ch')
      expect(response.body).to eq 'Im served from remote cache'
      LocalCacheInterceptor.cached = true
      response = LHC.get('http://local.ch')
      expect(response.body).to eq 'Im served from local cache'
    end
  end
end
