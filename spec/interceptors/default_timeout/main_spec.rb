require 'rails_helper'

describe LHC::DefaultTimeout do
  before(:each) do
    LHC.config.interceptors = [LHC::DefaultTimeout]
    LHC::DefaultTimeout.timeout = nil
    LHC::DefaultTimeout.connecttimeout = nil
  end

  let(:stub) { stub_request(:get, 'http://local.ch').to_return(status: 200, body: 'The Website') }

  it 'applies default timeouts to all requests made' do
    stub
    expect_any_instance_of(Ethon::Easy).to receive(:http_request)
      .with(anything, anything, hash_including(timeout: 15, connecttimeout: 2)).and_call_original
    LHC.get('http://local.ch')
  end

  context 'with changed default timesouts' do
    before(:each) do
      LHC::DefaultTimeout.timeout = 10
      LHC::DefaultTimeout.connecttimeout = 3
    end

    it 'applies custom default timeouts to all requests made' do
      stub
      expect_any_instance_of(Ethon::Easy).to receive(:http_request)
        .with(anything, anything, hash_including(timeout: 10, connecttimeout: 3)).and_call_original
      LHC.get('http://local.ch')
    end
  end
end
