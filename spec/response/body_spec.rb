require 'rails_helper'

describe LHC::Response do

  context 'body' do

    let(:body) { 'this is a body' }

    let(:raw_response) { OpenStruct.new({ body: body }) }

    it 'provides response body' do
      response = LHC::Response.new(raw_response, nil)
      expect(response.body).to eq body
    end
  end
end
