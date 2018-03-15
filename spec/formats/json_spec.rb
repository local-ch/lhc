require 'rails_helper'

describe LHC do
  context 'formats' do
    it 'adds Content-Type and Accept Headers to the request' do
      stub_request(:get, "http://local.ch/")
        .with(headers: { 'Accept' => 'application/json; charset=utf-8', 'Content-Type' => 'application/json; charset=utf-8' })
        .to_return(body: {}.to_json)
      LHC.json.get('http://local.ch')
    end
  end
end
