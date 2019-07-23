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
        break: '80%'
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

  # If LHC::Trottle.track would be kept accross multiple tests,
  # at least 2/3 of the following would fail

  it 'resets track' do
    LHC.get('http://local.ch', options)
  end

  it 'accross multiple' do
    LHC.get('http://local.ch', options)
  end

  it 'specs' do
    LHC.get('http://local.ch', options)
  end
end
