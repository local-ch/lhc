# frozen_string_literal: true

require 'rails_helper'

describe LHC::Request do
  let(:headers) { { private_key: 'xyz-123' } } # TODO it has a einfluss if you send a strin or symbol here
  let(:response) { LHC.get(:local, headers: headers) }
  let(:auth) { {} }

  before :each do
    LHC.config.endpoint(:local, 'http://local.ch', auth: auth)
    stub_request(:get, 'http://local.ch').with(headers: headers)
  end

  it 'scrubs "private_key"' do
    LHC.config.scrubs[:headers] << 'private_key'
    expect(response.request.scrubbed_headers).to include(private_key: LHC::Scrubber::SCRUB_DISPLAY)
  end

  it 'does not add a new attribute when a non existing header should be scrubbed' do
    LHC.config.scrubs[:headers] << 'anything'
    expect(response.request.scrubbed_headers).not_to include('anything' => LHC::Scrubber::SCRUB_DISPLAY)
  end

  context 'when strings instead of symbols are provided' do
    let(:headers) { { 'private_key' => 'xyz-123' } } # TODO it has a einfluss if you send a strin or symbol here

    it 'scrubs "private_key"' do
      LHC.config.scrubs[:headers] << 'private_key'
      expect(response.request.scrubbed_headers).to include('private_key' => LHC::Scrubber::SCRUB_DISPLAY)
    end
  end

  describe 'auth' do
    before :each do
      LHC.config.interceptors = [LHC::Auth]
      stub_request(:get, 'http://local.ch').with(headers: authorization_header)
    end

    let(:request) do
      response = LHC.get(:local)
      response.request
    end

    context 'bearer authentication' do
      let(:bearer_token) { '123456' }
      let(:authorization_header) { { 'Authorization' => "Bearer #{bearer_token}" } }
      let(:auth) { { bearer: -> { bearer_token } } }

      it 'provides srubbed request headers' do
        expect(request.scrubbed_headers).to include('Authorization' => "Bearer #{LHC::Scrubber::SCRUB_DISPLAY}")
        expect(request.headers).to include(authorization_header)
      end

      context 'when nothing should get scrubbed' do
        before :each do
          LHC.config.scrubs = {}
        end

        it 'does not filter beaerer auth' do
          expect(request.scrubbed_headers).to include(authorization_header)
        end
      end
    end

    context 'basic authentication' do
      let(:username) { 'steve' }
      let(:password) { 'abcdefg' }
      let(:credentials_base_64_codiert) { Base64.strict_encode64("#{username}:#{password}").chomp }
      let(:authorization_header) { { 'Authorization' => "Basic #{credentials_base_64_codiert}" } }
      let(:auth) { { basic: { username: username, password: password } } }

      it 'provides srubbed request headers' do
        expect(request.scrubbed_headers).to include('Authorization' => "Basic #{LHC::Scrubber::SCRUB_DISPLAY}")
        expect(request.headers).to include(authorization_header)
      end

      context 'when nothing should get scrubbed' do
        before :each do
          LHC.config.scrubs = {}
        end

        it 'does not filter basic auth' do
          expect(request.scrubbed_headers).to include(authorization_header)
        end
      end
    end
  end
end
