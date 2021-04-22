# frozen_string_literal: true

require 'rails_helper'

describe LHC::Auth do
  before(:each) do
    LHC.config.interceptors = [LHC::Auth]
  end

  # TODO Add this to REAMDE that logs and rollbar do fitler bearer token
  # TODO add to readme what is the default filtering
  # TODO Add to readme that when the filtering is overwritten the default does not take place anymore
  # TODO Maybe merge filtering then the defaul stays
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
