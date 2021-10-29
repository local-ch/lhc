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
  let(:cache) do
    { key: "LHS_REQUEST_CYCLE_CACHE(v1) POST http://local.ch?#{params}" }
  end

  let(:request) do
    response = LHC.post(:local, params: params, headers: headers, body: body, cache: cache)
    response.request
  end

  it 'provides srubbed request options' do
    expect(request.scrubbed_options[:params]).to include(api_key: LHC::Scrubber::SCRUB_DISPLAY)
    expect(request.scrubbed_options[:headers]).to include(private_key: LHC::Scrubber::SCRUB_DISPLAY)
    expect(request.scrubbed_options[:body]).to include(user_token: LHC::Scrubber::SCRUB_DISPLAY)
    expect(request.scrubbed_options[:auth][:bearer_token]).to eq(LHC::Scrubber::SCRUB_DISPLAY)
    expect(request.scrubbed_options[:auth][:basic]).to be nil
    expect(request.scrubbed_options[:cache])
      .to include(key: "LHS_REQUEST_CYCLE_CACHE(v1) POST http://local.ch?{:api_key=>\"[FILTERED]\"}")
  end

  context 'when bearer auth is not a proc' do
    let(:auth) { { bearer: bearer_token } }

    it 'also scrubbes the bearer' do
      expect(request.scrubbed_options[:auth][:bearer]).to eq(LHC::Scrubber::SCRUB_DISPLAY)
      expect(request.scrubbed_options[:auth][:bearer_token]).to eq(LHC::Scrubber::SCRUB_DISPLAY)
    end
  end

  context 'when options do not have auth' do
    let(:authorization_header) { {} }
    let(:auth) { nil }

    it 'provides srubbed request options' do
      expect(request.scrubbed_options[:params]).to include(api_key: LHC::Scrubber::SCRUB_DISPLAY)
      expect(request.scrubbed_options[:headers]).to include(private_key: LHC::Scrubber::SCRUB_DISPLAY)
      expect(request.scrubbed_options[:body]).to include(user_token: LHC::Scrubber::SCRUB_DISPLAY)
      expect(request.scrubbed_options[:auth]).to be nil
    end
  end

  context 'when parameter should not get scrubbed' do
    let(:params) { { any_parameter: 'any-parameter' } }

    let(:cache) do
      { key: "LHS_REQUEST_CYCLE_CACHE(v1) POST http://local.ch?#{params}" }
    end

    it 'does not scrubb the parameter' do
      expect(request.scrubbed_options[:cache])
        .to include(key: "LHS_REQUEST_CYCLE_CACHE(v1) POST http://local.ch?#{params}")
    end
  end

  context 'when body data is nested' do
    let(:body) do
      {
        data: {
          attributes: {
            employee: {
              name: 'Muster',
              surname: 'Hans',
              password: 'test-1234',
              password_confirmation: 'test-1234'
            }
          }
        }
      }
    end

    it 'srubbes nested attributes' do
      expect(request.scrubbed_options[:params]).to include(api_key: LHC::Scrubber::SCRUB_DISPLAY)
      expect(request.scrubbed_options[:headers]).to include(private_key: LHC::Scrubber::SCRUB_DISPLAY)
      expect(request.scrubbed_options[:body][:data][:attributes][:employee]).to include(password: LHC::Scrubber::SCRUB_DISPLAY)
      expect(request.scrubbed_options[:body][:data][:attributes][:employee]).to include(password_confirmation: LHC::Scrubber::SCRUB_DISPLAY)
      expect(request.scrubbed_options[:auth][:bearer_token]).to eq(LHC::Scrubber::SCRUB_DISPLAY)
      expect(request.scrubbed_options[:auth][:basic]).to be nil
    end
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
      expect(request.scrubbed_options[:cache])
        .not_to include(key: "LHS_REQUEST_CYCLE_CACHE(v1) POST http://local.ch?{:api_key=>\"[FILTERED]\"}")
    end
  end

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

    it 'provides srubbed request options' do
      expect(request.scrubbed_options[:body]).to include('user_token' => LHC::Scrubber::SCRUB_DISPLAY)
    end
  end

  context 'encoded data hash' do
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
      expect(request.scrubbed_options[:body]).to eq([user_token: LHC::Scrubber::SCRUB_DISPLAY])
    end
  end

  context 'encoded array' do
    let(:body) { [{ user_token: 'user-token-body' }] }

    let(:request) do
      response = LHC.post(:local, body: body.to_json)
      response.request
    end

    before :each do
      stub_request(:post, 'http://local.ch').with(body: body.to_json)
    end

    it 'provides srubbed request options' do
      expect(request.scrubbed_options[:body]).to eq(['user_token' => LHC::Scrubber::SCRUB_DISPLAY])
    end
  end
end
