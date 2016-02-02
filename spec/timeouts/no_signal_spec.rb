require 'rails_helper'

describe LHC::Request do
  context 'timeouts' do
    it 'has no_signal options set to true by default' do
      expect_any_instance_of(Ethon::Easy).to receive(:http_request).with(anything, anything, hash_including(nosignal: true)).and_call_original
      stub_request(:get, "http://local.ch/")
      LHC.get('http://local.ch')
    end
  end
end
