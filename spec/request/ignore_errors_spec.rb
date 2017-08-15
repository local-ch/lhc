require 'rails_helper'

describe LHC::Request do
  context 'ignore errors' do
    it 'raises errors for anything but 2XX response codes' do
      stub_request(:get, 'http://local.ch').to_return(status: 404)
      response = LHC.get('http://local.ch', ignored_errors: [LHC::NotFound])
      expect(response.body).to eq nil
      expect(response.data).to eq nil
      expect(response.success?).to eq false
    end
  end
end
