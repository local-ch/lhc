require 'rails_helper'

describe LHC::Request do

  it 'provides request headers' do
    stub_request(:get, 'http://local.ch')
    response = LHC.get('http://local.ch')
    request = response.request
    expect(request.headers).to eq({"User-Agent"=>"Typhoeus - https://github.com/typhoeus/typhoeus"})
  end
end
