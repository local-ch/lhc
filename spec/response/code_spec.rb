require 'rails_helper'

describe LHC::Response do

  context 'code' do

    let(:code) { 200 }

    it 'provides response code' do
      response = LHC::Response.new(
        OpenStruct.new({code: code})
      )
      expect(response.code).to eq code
    end
  end
end
