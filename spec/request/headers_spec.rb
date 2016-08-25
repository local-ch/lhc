require 'rails_helper'

describe LHC::Request do
  it 'provides request headers' do
    stub_request(:get, 'http://local.ch')
    response = LHC.get('http://local.ch')
    request = response.request
    expect(request.headers.keys).to eq(['User-Agent'])
  end
end
