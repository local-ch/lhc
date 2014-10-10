require 'rails_helper'

describe LHC::Response do

  context 'request' do

    let(:options) {{ method: :get }}

    let(:request) { OpenStruct.new({ options: options }) }

    let(:raw_response) { OpenStruct.new({request: request}) }

    it 'provides request_method' do
      response = LHC::Response.new(raw_response, nil)
      expect(response.request_method).to eq :get
    end
  end
end
