require 'rails_helper'

describe LHC::Response do

  context 'code' do

    let(:code) { 200 }

    let(:raw_response) { OpenStruct.new({ code: code }) }

    it 'provides response code' do
      response = LHC::Response.new(raw_response, nil)
      expect(response.code).to eq code
    end
  end
end
