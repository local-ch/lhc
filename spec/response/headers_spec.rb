require 'rails_helper'

describe LHC::Response do

  context 'headers' do

    let(:headers) do
      { 'Content-Encoding' => 'UTF-8' }
    end

    it 'provides headers' do
      response = LHC::Response.new(
        OpenStruct.new({headers: headers})
      )
      expect(response.headers).to eq headers
    end
  end
end
