require 'rails_helper'

describe LHC do

  context 'interceptor' do

    before(:each) do
      class CacheInterceptor < LHC::Interceptor

        def before_request(request)
          return LHC::Response.new(Typhoeus::Response.new(response_body: 'Im served from cache'), nil)
        end
      end
      LHC.config.interceptors = [CacheInterceptor]
    end

    it 'can return a response rather then doing a real request' do
      response = LHC.get('http://local.ch')
      expect(response.body).to eq 'Im served from cache'
    end

    context 'misusage' do

      before(:each) do
        class AnotherInterceptor < LHC::Interceptor
          def before_request(request)
            return LHC::Response.new(Typhoeus::Response.new({}), nil)
          end
        end
      end

      it 'raises an exception when two interceptors try to return a response' do
        expect(->{
          LHC.get('http://local.ch', interceptors: [CacheInterceptor, AnotherInterceptor])
        }).to raise_error 'Response already set from another interceptor'
      end
    end
  end
end
