require 'rails_helper'

describe LHC::Request do

  it 'does parallel requests if you provide an array of requests' do
    requests = []
    requests << { url: 'http://www.local.ch/restaurants' }
    requests << { url: 'http://www.local.ch' }
    stub_request(:get, "http://www.local.ch/restaurants").to_return(status: 200, body: '1')
    stub_request(:get, "http://www.local.ch").to_return(status: 200, body: '2')
    responses = LHC.request(requests)
    expect(responses[0].body).to eq '1'
    expect(responses[1].body).to eq '2'
  end
end
