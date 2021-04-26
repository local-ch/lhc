# frozen_string_literal: true

require 'rails_helper'

describe LHC::Request do
  before :each do
    LHC.config.interceptors = [LHC::Auth]
    LHC.config.endpoint(:local, 'http://local.ch', auth: auth)
    LHC.config.scrubs[:params] << 'api_key'
    LHC.config.scrubs[:headers] << 'private_key'
    LHC.config.scrubs[:body] << 'user_token'
    stub_request(:post, "http://local.ch?#{params.to_query}").with(headers: authorization_header.merge(headers), body: body.to_json)
  end

  let(:bearer_token) { '123456' }
  let(:authorization_header) { { 'Authorization' => "Bearer #{bearer_token}" } }
  let(:auth) { { bearer: -> { bearer_token } } }
  let(:params) { { api_key: 'api-key-params' } }
  let(:headers) { { private_key: 'private-key-header' } }
  let(:body) { { user_token: 'user-token-body' } }

  let(:request) do
    response = LHC.post(:local, params: params, headers: headers, body: body)
    response.request
  end

  it 'provides srubbed request options' do
    expect(request.scrubbed_options[:params]).to include('api_key' => '[FILTERED]')
    expect(request.scrubbed_options[:headers]).to include('Authorization' => 'Bearer [FILTERED]')
    expect(request.scrubbed_options[:headers]).to include('private_key' => '[FILTERED]')
    expect(request.scrubbed_options[:body]).to include('user_token' => '[FILTERED]')
  end
end
