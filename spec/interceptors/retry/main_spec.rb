# frozen_string_literal: true

require 'rails_helper'

describe LHC::Rollbar do
  before(:each) do
    LHC.config.interceptors = [LHC::Retry]
  end

  let(:request_stub) do
    @retry_count = 0
    stub_request(:get, 'http://local.ch').to_return do |_|
      if @retry_count == max_retry_count
        { status: 200 }
      else
        @retry_count += 1
        { status: 500 }
      end
    end
  end

  let(:max_retry_count) { 3 }

  it 'retries a request up to 3 times (default)' do
    request_stub
    response = LHC.get('http://local.ch', retry: true)
    expect(response.success?).to eq true
    expect(response.code).to eq 200
    expect(request_stub).to have_been_requested.times(4)
  end

  context 'retry only once' do
    let(:retry_options) { { max: 1 } }
    let(:max_retry_count) { 1 }

    it 'retries only once' do
      request_stub
      response = LHC.get('http://local.ch', retry: { max: 1 })
      expect(response.success?).to eq true
      expect(response.code).to eq 200
      expect(request_stub).to have_been_requested.times(2)
    end
  end

  context 'retry all' do

    let(:max_retry_count) { 2 }

    before do
      expect(LHC::Retry).to receive(:max).at_least(:once).and_return(2)
      expect(LHC::Retry).to receive(:all).at_least(:once).and_return(true)
    end

    it 'retries if configured globally' do
      request_stub
      response = LHC.get('http://local.ch')
      expect(response.success?).to eq true
      expect(response.code).to eq 200
      expect(request_stub).to have_been_requested.times(3)
    end
  end
end
