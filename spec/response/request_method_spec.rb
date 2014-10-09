require 'rails_helper'

describe LHC::Response do

  context 'request' do

    let(:options) {{ method: :get }}

    let(:request) { OpenStruct.new({ options: options }) }

    it 'provides request_method' do
      response = LHC::Response.new(
        OpenStruct.new({request: request})
      )
      expect(response.request_method).to eq :get
    end
  end
end
