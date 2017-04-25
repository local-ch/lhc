require 'rails_helper'

describe LHC::Rollbar do
  before(:each) do
    LHC.config.interceptors = [LHC::Rollbar]
  end

  it 'does not report if Rollbar is not defined' do
    stub_request(:get, 'http://local.ch').to_return(status: 400)
    expect(-> { LHC.get('http://local.ch') })
      .to raise_error LHC::BadRequest
  end

  context 'Rollbar is defined' do
    before(:each) do
      class Rollbar; end
      allow(::Rollbar).to receive(:warning)
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

    context 'additional params' do
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
    end
  end
end