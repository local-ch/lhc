require 'rails_helper'

describe LHC::Response do

  context 'options' do

    let(:options) { { followlocation: true } }

    let(:request) { OpenStruct.new({ options: options }) }

    let(:raw_response) { OpenStruct.new({request: request}) }

    it 'provides response options' do
      response = LHC::Response.new(raw_response, nil)
      expect(response.request_options).to eq options
    end
  end
end
