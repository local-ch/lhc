require 'rails_helper'

describe LHC::Response do

  context 'request' do

    let(:url) { 'http://local.ch' }

    let(:request) { OpenStruct.new({ base_url: url }) }

    let(:raw_response) { OpenStruct.new({request: request}) }

    it 'provides request_url' do
      response = LHC::Response.new(raw_response, nil)
      expect(response.request_url).to eq url
    end
  end
end
