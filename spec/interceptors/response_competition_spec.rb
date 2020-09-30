# frozen_string_literal: true

require 'rails_helper'

describe LHC do
  context 'interceptor response competition' do
    before(:each) do
      # rubocop:disable Style/ClassVars
      class LocalCacheInterceptor < LHC::Interceptor
        @@cached = false
        cattr_accessor :cached

        def before_request
          if @@cached
            return LHC::Response.new(Typhoeus::Response.new(response_code: 200, return_code: :ok, response_body: 'Im served from local cache'), nil)
          end
        end
      end
      # rubocop:enable Style/ClassVars

      class RemoteCacheInterceptor < LHC::Interceptor

        def before_request
          if request.response.nil?
            return LHC::Response.new(Typhoeus::Response.new(response_code: 200, return_code: :ok, response_body: 'Im served from remote cache'), nil)
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
