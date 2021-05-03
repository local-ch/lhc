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
    expect(request.scrubbed_options[:params]).to include(api_key: LHC::Scrubber::SCRUB_DISPLAY)
    expect(request.scrubbed_options[:headers]).to include(private_key: LHC::Scrubber::SCRUB_DISPLAY)
    expect(request.scrubbed_options[:body]).to include(user_token: LHC::Scrubber::SCRUB_DISPLAY)
    expect(request.scrubbed_options[:auth][:bearer_token]).to eq(LHC::Scrubber::SCRUB_DISPLAY)
    expect(request.scrubbed_options[:auth][:basic]).to be nil
  end

  context 'basic authentication' do
    let(:username) { 'steve' }
    let(:password) { 'abcdefg' }
    let(:credentials_base_64_codiert) { Base64.strict_encode64("#{username}:#{password}").chomp }
    let(:authorization_header) { { 'Authorization' => "Basic #{credentials_base_64_codiert}" } }
    let(:auth) { { basic: { username: username, password: password } } }

    it 'provides srubbed request headers' do
      expect(request.scrubbed_options[:auth][:basic][:username]).to eq(LHC::Scrubber::SCRUB_DISPLAY)
      expect(request.scrubbed_options[:auth][:basic][:password]).to eq(LHC::Scrubber::SCRUB_DISPLAY)
      expect(request.scrubbed_options[:auth][:basic][:base_64_encoded_credentials]).to eq(LHC::Scrubber::SCRUB_DISPLAY)
      expect(request.scrubbed_options[:auth][:bearer]).to be nil
    end
  end

  context 'when nothing should get scrubbed' do
    before :each do
      LHC.config.scrubs = {}
    end

    it 'does not filter anything' do
      expect(request.scrubbed_options[:params]).not_to include(api_key: LHC::Scrubber::SCRUB_DISPLAY)
      expect(request.scrubbed_options[:headers]).not_to include(private_key: LHC::Scrubber::SCRUB_DISPLAY)
      expect(request.scrubbed_options[:body]).not_to include(user_token: LHC::Scrubber::SCRUB_DISPLAY)
      expect(request.scrubbed_options[:auth][:bearer_token]).not_to eq(LHC::Scrubber::SCRUB_DISPLAY)
    end
  end

  # TODO write down that the configs for scrubbing are aplied to all requests

  context 'custom data structures that respond to as_json (like LHS data or record)' do
    before do
      class CustomStructure

        def initialize(data)
          @data = data
        end

        def as_json
          @data.as_json
        end

        def to_json
          as_json.to_json
        end
      end

      stub_request(:post, 'http://local.ch').with(body: custom_structure.to_json)
    end

    let(:custom_structure) do
      CustomStructure.new(user_token: '12345')
    end

    let(:request) do
      response = LHC.post(:local, body: custom_structure)
      response.request
    end

    # TODO is this the right thing to do? Shall we parse custom data?
    it 'provides srubbed request options' do
      expect(request.scrubbed_options[:body]).to include('user_token' => LHC::Scrubber::SCRUB_DISPLAY)
    end
  end

  context 'encoded data' do
    let(:body) { { user_token: 'user-token-body' } }

    let(:request) do
      response = LHC.post(:local, body: body.to_json)
      response.request
    end

    before :each do
      stub_request(:post, 'http://local.ch').with(body: body.to_json)
    end

    it 'provides srubbed request options' do
      expect(request.scrubbed_options[:body]).to include('user_token' => LHC::Scrubber::SCRUB_DISPLAY)
    end
  end

  # TODO go on here
  # TODO test also this context
  context 'array' do
    let(:body) { [{ user_token: 'user-token-body' }] }

    let(:request) do
      response = LHC.post(:local, body: body)
      response.request
    end

    before :each do
      stub_request(:post, 'http://local.ch').with(body: body.to_json)
    end

    it 'provides srubbed request options' do
      expect(request.scrubbed_options[:body]).not_to include(user_token: LHC::Scrubber::SCRUB_DISPLAY)
    end
  end

    #it 'does not encode the request body if it is already a string' do
    #  LHC.post('http://datastore/q', body: encoded_data)
    #end
end
