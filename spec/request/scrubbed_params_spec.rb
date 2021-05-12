# frozen_string_literal: true

require 'rails_helper'

describe LHC::Request do
  let(:params) { { api_key: 'xyz-123', secret_key: '123-xyz' } }
  let(:response) { LHC.get(:local, params: params) }

  before :each do
    LHC.config.endpoint(:local, 'http://local.ch')
    stub_request(:get, "http://local.ch?#{params.to_query}")
  end

  it 'scrubs "api_key"' do
    LHC.config.scrubs[:params] << 'api_key'
    expect(response.request.scrubbed_params).to include(api_key: LHC::Scrubber::SCRUB_DISPLAY)
    expect(response.request.scrubbed_params).to include(secret_key: '123-xyz')
  end

  it 'scrubs "api_key" and "secret_key"' do
    LHC.config.scrubs[:params].push('api_key', 'secret_key')
    expect(response.request.scrubbed_params).to include(api_key: LHC::Scrubber::SCRUB_DISPLAY)
    expect(response.request.scrubbed_params).to include(secret_key: LHC::Scrubber::SCRUB_DISPLAY)
  end

  context 'when value is empty' do
    let(:params) { { api_key: nil, secret_key: '' } }

    it 'does not filter the value' do
      LHC.config.scrubs[:params].push('api_key', 'secret_key')
      expect(response.request.scrubbed_params).to include(api_key: nil)
      expect(response.request.scrubbed_params).to include(secret_key: '')
    end
  end
end
