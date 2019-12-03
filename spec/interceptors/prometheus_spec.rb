# frozen_string_literal: true

require 'rails_helper'
require 'prometheus/client'

describe LHC::Prometheus do
  before(:each) do
    LHC.config.interceptors = [LHC::Prometheus]
    LHC::Prometheus.client = Prometheus::Client
    LHC::Prometheus.namespace = 'test_app'
    stub_request(:get, 'http://local.ch')
    expect(Prometheus::Client).to receive(:registry).and_call_original.at_least(:once)
  end

  let(:client) { double("prometheus/client") }

  context 'registering' do
    it 'creates a counter and histogram registry in the prometheus client' do
      expect(Prometheus::Client.registry).to receive(:counter).and_call_original.once
        .with(:test_app_lhc_requests, 'Counter of all LHC requests.')
      expect(Prometheus::Client.registry).to receive(:histogram).and_call_original.once
        .with(:test_app_lhc_times, 'Times for all LHC requests (Deprecated)')
      expect(Prometheus::Client.registry).to receive(:histogram).and_call_original.once
        .with(:test_app_lhc_request_seconds, 'Request timings for all LHC requests in seconds.')

      LHC.get('http://local.ch')
      LHC.get('http://local.ch') # second request, registration should happen only once
    end
  end

  context 'logging' do
    let(:requests_registry_double) { double('requests_registry_double') }
    let(:deprecated_times_registry_double) { double('deprecated_times_registry_double') }
    let(:times_registry_double) { double('times_registry_double') }

    it 'logs monitoring information to the created registries' do
      expect(Prometheus::Client.registry).to receive(:get).and_return(requests_registry_double).once
        .with(:test_app_lhc_requests)
      expect(Prometheus::Client.registry).to receive(:get).and_return(deprecated_times_registry_double).once
        .with(:test_app_lhc_times)
      expect(Prometheus::Client.registry).to receive(:get).and_return(times_registry_double).once
        .with(:test_app_lhc_request_seconds)

      expect(requests_registry_double).to receive(:increment).once
        .with(
          code: 200,
          success: true,
          timeout: false,
          host: 'local.ch'
        )

      expect(deprecated_times_registry_double).to receive(:observe).once
        .with({}, 0)

      expect(times_registry_double).to receive(:observe).once
        .with({ host: 'local.ch' }, 0)

      LHC.get('http://local.ch')
    end
  end
end
