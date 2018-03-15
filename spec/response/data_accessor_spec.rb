require 'rails_helper'

describe LHC do
  context 'data accessor (hash with indifferent access)' do
    before(:each) do
      stub_request(:get, "http://local.ch/")
        .with(headers: { 'Accept' => 'application/json; charset=utf-8', 'Content-Type' => 'application/json; charset=utf-8' })
        .to_return(body: { 'MyProp' => 'MyValue' }.to_json)
    end

    it 'makes data accessible with square bracket accessor (string)' do
      expect(
        LHC.json.get('http://local.ch')['MyProp']
      ).to eq 'MyValue'
    end

    it 'makes data accessible with square bracket accessor (symbol)' do
      expect(
        LHC.json.get('http://local.ch')[:MyProp]
      ).to eq 'MyValue'
    end
  end
end
