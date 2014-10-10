require 'rails_helper'

describe LHC::Response do

  context 'options' do

    let(:options) { { followlocation: true } }

    let(:request) { OpenStruct.new({ options: options }) }

    it 'provides response options' do
      response = LHC::Response.new(
        OpenStruct.new({request: request})
      )
      expect(response.request_options).to eq options
    end
  end
end
