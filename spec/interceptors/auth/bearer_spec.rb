# frozen_string_literal: true

require 'rails_helper'

describe LHC::Auth do
  before(:each) do
    LHC.config.interceptors = [LHC::Auth]
  end

  it 'adds the bearer token to every request' do
    def bearer_token
      '123456'
    end
    options = { bearer: -> { bearer_token } }
    LHC.config.endpoint(:local, 'http://local.ch', auth: options)
    stub_request(:get, 'http://local.ch').with(headers: { 'Authorization' => 'Bearer 123456' })
    LHC.get(:local)
  end
end
