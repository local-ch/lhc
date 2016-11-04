require 'rails_helper'

describe LHC do
  context 'data accessor' do
    it 'makes data accessible with square bracket accessor' do
      stub_request(:get, "http://local.ch/")
        .with(headers: { 'Accept' => 'application/json', 'Content-Type' => 'application/json' })
        .to_return(body: { 'MyProp' => 'MyValue' }.to_json)
      expect(
        LHC.json.get('http://local.ch')['MyProp']
      ).to eq 'MyValue'
    end
  end
end
