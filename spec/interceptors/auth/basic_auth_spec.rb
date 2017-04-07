require 'rails_helper'

describe LHC::Auth do
  before(:each) do
    LHC.config.interceptors = [LHC::Auth]
  end

  it 'adds basic auth to every request' do
    options = { basic: { username: 'steve', password: 'can' } }
    LHC.config.endpoint(:local, 'http://local.ch', auth: options)
    stub_request(:get, 'http://local.ch')
      .with(headers: { 'Authorization' => 'Basic c3RldmU6Y2Fu' })
    LHC.get(:local)
  end
end
