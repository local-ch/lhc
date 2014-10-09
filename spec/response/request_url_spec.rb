require 'rails_helper'

describe LHC::Response do

  context 'request' do

    let(:url) { 'http://local.ch' }

    let(:request) { OpenStruct.new({ base_url: url }) }

    it 'provides request_url' do
      response = LHC::Response.new(
        OpenStruct.new({request: request})
      )
      expect(response.request_url).to eq url
    end
  end
end
