# frozen_string_literal: true

require 'rails_helper'

describe LHC::Throttle do
  let(:provider) { 'local.ch' }
  let(:limit) { 10000 }
  let(:remaining) { 1900 }
  let(:options) do
    {
      throttle: {
        provider: provider,
        track: true,
        limit: limit_options,
        remaining: { header: 'Rate-Limit-Remaining' },
        expires: { header: 'Rate-Limit-Reset' },
        break: break_option
      }
    }
  end
  let(:limit_options) { { header: 'Rate-Limit-Limit' } }
  let(:break_option) { false }
  let(:expires_in) { (Time.zone.now + 1.hour).to_i }

  before(:each) do
    LHC::Throttle.track = nil
    LHC.config.interceptors = [LHC::Throttle]

    stub_request(:get, 'http://local.ch')
      .to_return(
        headers: {
          'Rate-Limit-Limit' => limit,
          'Rate-Limit-Remaining' => remaining,
          'Rate-Limit-Reset' => expires_in
        }
      )
  end

  it 'tracks the request limits based on response data' do
    LHC.get('http://local.ch', options)
    expect(LHC::Throttle.track[provider][:limit]).to eq limit
    expect(LHC::Throttle.track[provider][:remaining]).to eq remaining
  end

  context 'fix predefined integer for limit' do
    let(:limit_options) { 1000 }

    it 'tracks the limit based on initialy provided data' do
      LHC.get('http://local.ch', options)
      expect(LHC::Throttle.track[provider][:limit]).to eq limit_options
    end
  end

  context 'breaks' do
    let(:break_option) { '80%' }

    it 'hit the breaks if throttling quota is reached' do
      LHC.get('http://local.ch', options)
      expect(-> {
        LHC.get('http://local.ch', options)
      }).to raise_error(LHC::Throttle::OutOfQuota, 'Reached predefined quota for local.ch')
    end

    context 'still within quota' do
      let(:break_option) { '90%' }

      it 'does not hit the breaks' do
        LHC.get('http://local.ch', options)
        LHC.get('http://local.ch', options)
      end
    end
  end

  context 'no response headers' do
    before do
      stub_request(:get, 'http://local.ch')
        .to_return(status: 200)
    end

    it 'does not raise an exception' do
      LHC.get('http://local.ch', options)
    end

    context 'no remaining tracked, but break enabled' do
      let(:break_option) { '90%' }

      it 'does not fail if a remaining was not tracked yet' do
        LHC.get('http://local.ch', options)
        LHC.get('http://local.ch', options)
      end
    end
  end

  context 'expires' do
    let(:break_option) { '80%' }

    it 'attempts another request if the quota expired' do
      LHC.get('http://local.ch', options)
      expect(-> {
        LHC.get('http://local.ch', options)
      }).to raise_error(LHC::Throttle::OutOfQuota, 'Reached predefined quota for local.ch')
      Timecop.travel(Time.zone.now + 2.hours)
      LHC.get('http://local.ch', options)
    end
  end
end
