# frozen_string_literal: true

require 'rails_helper'

describe LHC::Request do
  let(:params) { { api_key: 'xyz-123' } }
  let(:response) { LHC.get(:local, params: params) }

  before :each do
    LHC.config.endpoint(:local, 'http://local.ch')
    stub_request(:get, "http://local.ch?#{params.to_query}")
  end

  it 'scrubs "private_key"' do
    LHC.config.scrubs[:params] << 'api_key'
    expect(response.request.scrubbed_params).to include('api_key' => '[FILTERED]')
  end
end
