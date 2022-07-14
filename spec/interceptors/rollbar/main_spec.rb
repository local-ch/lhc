# frozen_string_literal: true

require 'rails_helper'

describe LHC::Rollbar do
  before(:each) do
    LHC.config.interceptors = [LHC::Rollbar]
  end

  context 'Rollbar is undefined' do
    before(:each) do
      Object.send(:remove_const, 'Rollbar') if Object.const_defined?(:Rollbar)
    end
    it 'does not report' do
      stub_request(:get, 'http://local.ch').to_return(status: 400)
      expect(-> { LHC.get('http://local.ch') })
        .to raise_error LHC::BadRequest
    end
  end

  context 'Rollbar is defined' do
    before(:each) do
      class Rollbar; end
      ::Rollbar.stub(:warning)
    end

    it 'does report errors to rollbar' do
      stub_request(:get, 'http://local.ch').to_return(status: 400)
      expect(-> { LHC.get('http://local.ch') })
        .to raise_error LHC::BadRequest
      expect(::Rollbar).to have_received(:warning)
        .with(
          'Status: 400 URL: http://local.ch',
          response: hash_including(body: anything, code: anything, headers: anything, time: anything, timeout?: anything),
          request: hash_including(url: anything, method: anything, headers: anything, params: anything)
        )
    end

    it 'does report errors to rollbar with additional data' do
      stub_request(:get, 'http://local.ch')
        .to_return(status: 400)
      expect(-> { LHC.get('http://local.ch', rollbar: { additional: 'data' }) })
        .to raise_error LHC::BadRequest
      expect(::Rollbar).to have_received(:warning)
        .with(
          'Status: 400 URL: http://local.ch',
          hash_including(
            response: anything,
            request: anything,
            additional: 'data'
          )
        )
    end

    it 'scrubs sensitive data' do
      LHC.config.scrubs[:params] << 'api_key'
      LHC.config.scrubs[:headers] << 'private_key'
      stub_request(:get, 'http://local.ch?api_key=123-abc').to_return(status: 400)
      expect(-> { LHC.get('http://local.ch', params: { api_key: '123-abc' }, headers: { private_key: 'abc-123' }) })
        .to raise_error LHC::BadRequest
      expect(::Rollbar).to have_received(:warning)
        .with(
          'Status: 400 URL: http://local.ch',
          response: hash_including(body: anything, code: anything, headers: anything, time: anything, timeout?: anything),
          request: hash_including(url: anything, method: anything, headers: hash_including(private_key: LHC::Scrubber::SCRUB_DISPLAY), params: { api_key: LHC::Scrubber::SCRUB_DISPLAY })
        )
    end

    context 'ignored errors' do
      it 'does not report to rollbar if the error is ignored' do
        stub_request(:get, 'http://local.ch').to_return(status: 404)
        LHC.get('http://local.ch', ignore: [LHC::NotFound])
        expect(::Rollbar).not_to have_received(:warning)
      end

      it 'does report to rollbar' do
        stub_request(:get, 'http://local.ch').to_return(status: 400)
        expect(-> { LHC.get('http://local.ch', ignore: [LHC::NotFound]) }).to raise_error LHC::BadRequest
        expect(::Rollbar).not_to have_received(:warning)
          .with(
            'Status: 400 URL: http://local.ch',
            response: hash_including(body: anything, code: anything, headers: anything, time: anything, timeout?: anything),
            request: hash_including(url: anything, method: anything, headers: hash_including(private_key: LHC::Scrubber::SCRUB_DISPLAY), params: { api_key: LHC::Scrubber::SCRUB_DISPLAY })
          )
      end
    end
  end
end
