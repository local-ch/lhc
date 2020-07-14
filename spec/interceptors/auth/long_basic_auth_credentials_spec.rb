# frozen_string_literal: true

require 'rails_helper'

describe LHC::Auth do
  before(:each) do
    LHC.config.interceptors = [LHC::Auth]
  end

  it 'adds basic auth in a correct way even if username and password are especially long' do
    options = { basic: { username: '123456789101234', password: '12345678901234567890123456789012' } }
    LHC.config.endpoint(:local, 'http://local.ch', auth: options)
    stub_request(:get, 'http://local.ch')
      .with(headers: { 'Authorization' => 'Basic MTIzNDU2Nzg5MTAxMjM0OjEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEy' })
    LHC.get(:local)
  end
end
