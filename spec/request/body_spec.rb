require 'rails_helper'

describe LHC::Request do
  context 'encode body' do
    let(:data) { { name: 'Steve' } }
    let(:encoded_data) { data.to_json }

    before do
      stub_request(:post, "http://datastore/q")
        .with(body: encoded_data)
        .to_return(status: 200)
    end

    it 'encodes the request body to the given format' do
      LHC.post('http://datastore/q', body: data)
    end

    it 'does not encode the request body if it is already a string' do
      LHC.post('http://datastore/q', body: encoded_data)
    end
  end
end
