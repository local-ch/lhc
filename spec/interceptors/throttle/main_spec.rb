# frozen_string_literal: true

require 'rails_helper'

describe LHC::Throttle do
  let(:options_break) { false }
  let(:options_expires) { { header: 'reset' } }
  let(:options_limit) { { header: 'limit' } }
  let(:options_remaining) { { header: 'remaining' } }
  let(:provider) { 'local.ch' }
  let(:quota_limit) { 10_000 }
  let(:quota_remaining) { 1900 }
  let(:quota_reset) { (Time.zone.now + 1.hour).to_i }
  let(:options) do
    {
      throttle: {
        provider: provider,
        track: true,
        limit: options_limit,
        remaining: options_remaining,
        expires: options_expires,
        break: options_break
      }
    }
  end

  before(:each) do
    LHC::Throttle.track = nil
    LHC.config.interceptors = [LHC::Throttle]

    stub_request(:get, 'http://local.ch').to_return(
      headers: { 'limit' => quota_limit, 'remaining' => quota_remaining, 'reset' => quota_reset }
    )
  end

  it 'tracks the request limits based on response data' do
    LHC.get('http://local.ch', options)
    expect(LHC::Throttle.track[provider][:limit]).to eq quota_limit
    expect(LHC::Throttle.track[provider][:remaining]).to eq quota_remaining
  end

  context 'fix predefined integer for limit' do
    let(:options_limit) { 1000 }

    it 'tracks the limit based on initialy provided data' do
      LHC.get('http://local.ch', options)
      expect(LHC::Throttle.track[provider][:limit]).to eq options_limit
    end
  end

  context 'breaks' do
    let(:options_break) { '80%' }

    it 'hit the breaks if throttling quota is reached' do
      LHC.get('http://local.ch', options)
      expect { LHC.get('http://local.ch', options) }.to raise_error(
        LHC::Throttle::OutOfQuota,
        'Reached predefined quota for local.ch'
      )
    end

    context 'still within quota' do
      let(:options_break) { '90%' }

      it 'does not hit the breaks' do
        LHC.get('http://local.ch', options)
        LHC.get('http://local.ch', options)
      end
    end
  end

  context 'no response headers' do
    before { stub_request(:get, 'http://local.ch').to_return(status: 200) }

    it 'does not raise an exception' do
      LHC.get('http://local.ch', options)
    end

    context 'no remaining tracked, but break enabled' do
      let(:options_break) { '90%' }

      it 'does not fail if a remaining was not tracked yet' do
        LHC.get('http://local.ch', options)
        LHC.get('http://local.ch', options)
      end
    end
  end

  context 'expires' do
    let(:options_break) { '80%' }

    it 'attempts another request if the quota expired' do
      LHC.get('http://local.ch', options)
      expect { LHC.get('http://local.ch', options) }.to raise_error(
        LHC::Throttle::OutOfQuota,
        'Reached predefined quota for local.ch'
      )
      Timecop.travel(Time.zone.now + 2.hours)
      LHC.get('http://local.ch', options)
    end
  end

  describe 'calculate "remaining" in proc' do
    let(:quota_current) { 8100 }
    let(:options_remaining) do
      ->(response) { (response.headers['limit']).to_i - (response.headers['current']).to_i }
    end

    before(:each) do
      stub_request(:get, 'http://local.ch').to_return(
        headers: { 'limit' => quota_limit, 'current' => quota_current, 'reset' => quota_reset }
      )
      LHC.get('http://local.ch', options)
    end

    context 'breaks' do
      let(:options_break) { '80%' }

      it 'hit the breaks if throttling quota is reached' do
        expect { LHC.get('http://local.ch', options) }.to raise_error(
          LHC::Throttle::OutOfQuota,
          'Reached predefined quota for local.ch'
        )
      end

      context 'still within quota' do
        let(:options_break) { '90%' }

        it 'does not hit the breaks' do
          LHC.get('http://local.ch', options)
          LHC.get('http://local.ch', options)
        end
      end
    end
  end

  describe 'parsing reset time given in prose' do
    let(:quota_reset) { (Time.zone.now + 1.day).strftime('%A, %B %d, %Y 12:00:00 AM GMT').to_s }

    before { LHC.get('http://local.ch', options) }

    context 'breaks' do
      let(:options_break) { '80%' }

      it 'hit the breaks if throttling quota is reached' do
        expect { LHC.get('http://local.ch', options) }.to raise_error(
          LHC::Throttle::OutOfQuota,
          'Reached predefined quota for local.ch'
        )
      end

      context 'still within quota' do
        let(:options_break) { '90%' }

        it 'does not hit the breaks' do
          LHC.get('http://local.ch', options)
          LHC.get('http://local.ch', options)
        end
      end
    end
  end
end
