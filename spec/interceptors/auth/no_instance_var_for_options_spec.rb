# frozen_string_literal: true

require 'rails_helper'

describe LHC::Auth do
  before(:each) do
    class AuthPrepInterceptor < LHC::Interceptor

      def before_request
        request.options[:auth] = { bearer: 'sometoken' }
      end
    end

    LHC.config.interceptors = [AuthPrepInterceptor, LHC::Auth]
  end

  after do
    LHC.config.reset
  end

  it 'does not use instance variables internally so that other interceptors can still change auth options' do
    stub_request(:get, "http://local.ch/")
      .with(headers: { 'Authorization' => 'Bearer sometoken' })
        .to_return(status: 200)
    LHC.get('http://local.ch')
  end
end
