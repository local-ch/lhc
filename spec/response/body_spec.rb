require 'rails_helper'

describe LHC::Response do

  context 'body' do

    let(:body) { 'this is a body' }

    it 'provides response body' do
      response = LHC::Response.new(
        OpenStruct.new({body: body})
      )
      expect(response.body).to eq body
    end
  end
end
