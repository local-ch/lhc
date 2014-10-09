require 'rails_helper'

describe LHC::Response do

  context 'code' do

    let(:code) { 200 }

    it 'provides response code' do
      response = LHC::Response.new(
        OpenStruct.new({code: 200})
      )
      expect(response.code).to eq 200
    end
  end
end
