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
        break: break_option
      }
    }
  end
  let(:limit_options) { { header: 'Rate-Limit-Limit' } }
  let(:break_option) { false }

  before(:each) do
    LHC::Throttle.track = nil
    LHC.config.interceptors = [LHC::Throttle]

    stub_request(:get, 'http://local.ch')
      .to_return(headers: {
        'Rate-Limit-Limit' => limit,
        'Rate-Limit-Remaining' => remaining
      })
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
end
