require 'rails_helper'

describe LHC::Response do

  context 'data' do

    let(:value) { 'some_value' }

    let(:body) {{ some_key: value }}

    let(:raw_response) { OpenStruct.new({ body: body.to_json }) }

    it 'makes data from response body available' do
      response = LHC::Response.new(raw_response, nil)
      expect(response.data.some_key).to eq value
    end
  end
end
