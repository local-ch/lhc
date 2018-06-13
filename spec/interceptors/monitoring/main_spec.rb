require 'rails_helper'

describe LHC::Monitoring do
  let(:stub) { stub_request(:get, 'http://local.ch').to_return(status: 200, body: 'The Website') }
  let(:endpoint_configuration) { LHC.config.endpoint(:local, 'http://local.ch') }

  module Statsd
    def self.count(_path, _value); end

    def self.timing(_path, _value); end
  end

  before(:each) do
    LHC.config.interceptors = [LHC::Monitoring]
    LHC::Monitoring.statsd = Statsd
    Rails.cache.clear
    endpoint_configuration
  end

  it 'does not report anything if no statsd is configured' do
    stub
    LHC.get(:local) # and also does not crash ;)
  end

  context 'statsd configured' do
    it 'reports trial, response and timing by default ' do
      stub
      expect(Statsd).to receive(:count).with('lhc.dummy.test.local_ch.get.before_request', 1)
      expect(Statsd).to receive(:count).with('lhc.dummy.test.local_ch.get.after_request', 1)
      expect(Statsd).to receive(:count).with('lhc.dummy.test.local_ch.get.count', 1)
      expect(Statsd).to receive(:count).with('lhc.dummy.test.local_ch.get.200', 1)
      expect(Statsd).to receive(:timing).with('lhc.dummy.test.local_ch.get.time', anything)
      LHC.get(:local)
    end

    it 'does not report timing when response failed' do
      stub_request(:get, 'http://local.ch').to_return(status: 500)
      expect(Statsd).to receive(:count).with('lhc.dummy.test.local_ch.get.before_request', 1)
      expect(Statsd).to receive(:count).with('lhc.dummy.test.local_ch.get.after_request', 1)
      expect(Statsd).to receive(:count).with('lhc.dummy.test.local_ch.get.count', 1)
      expect(Statsd).to receive(:count).with('lhc.dummy.test.local_ch.get.500', 1)
      expect(Statsd).not_to receive(:timing)
      expect { LHC.get(:local) }.to raise_error LHC::ServerError
    end

    it 'reports timeout instead of status code if response timed out' do
      stub_request(:get, 'http://local.ch').to_timeout
      expect(Statsd).to receive(:count).with('lhc.dummy.test.local_ch.get.before_request', 1)
      expect(Statsd).to receive(:count).with('lhc.dummy.test.local_ch.get.after_request', 1)
      expect(Statsd).to receive(:count).with('lhc.dummy.test.local_ch.get.count', 1)
      expect(Statsd).to receive(:count).with('lhc.dummy.test.local_ch.get.timeout', 1)
      expect(Statsd).not_to receive(:timing)
      expect { LHC.get(:local) }.to raise_error LHC::Timeout
    end

    it 'allows to set the stats key for request' do
      stub
      expect(Statsd).to receive(:count).with('defined_key.before_request', 1)
      expect(Statsd).to receive(:count).with('defined_key.after_request', 1)
      expect(Statsd).to receive(:count).with('defined_key.count', 1)
      expect(Statsd).to receive(:count).with('defined_key.200', 1)
      expect(Statsd).to receive(:timing).with('defined_key.time', anything)
      LHC.get(:local, monitoring_key: 'defined_key')
    end
  end

  context 'without protocol' do
    let(:endpoint_configuration) { LHC.config.endpoint(:local, 'local.ch') }

    it 'reports trial, response and timing by default ' do
      stub
      expect(Statsd).to receive(:count).with('lhc.dummy.test.local_ch.get.before_request', 1)
      expect(Statsd).to receive(:count).with('lhc.dummy.test.local_ch.get.after_request', 1)
      expect(Statsd).to receive(:count).with('lhc.dummy.test.local_ch.get.count', 1)
      expect(Statsd).to receive(:count).with('lhc.dummy.test.local_ch.get.200', 1)
      expect(Statsd).to receive(:timing).with('lhc.dummy.test.local_ch.get.time', anything)
      LHC.get(:local)
    end
  end
end
