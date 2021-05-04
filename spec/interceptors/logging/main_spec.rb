# frozen_string_literal: true

require 'rails_helper'

describe LHC::Logging do
  let(:logger) { spy('logger') }

  before(:each) do
    LHC.config.interceptors = [LHC::Logging]
    LHC::Logging.logger = logger
    stub_request(:get, /http:\/\/local.ch.*/).to_return(status: 200)
  end

  it 'does log information before and after every request made with LHC' do
    LHC.get('http://local.ch')
    expect(logger).to have_received(:info).once.with(
      %r{Before LHC request <\d+> GET http://local.ch at \d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\+\d{2}:\d{2} Params={} Headers={.*?}}
    )
    expect(logger).to have_received(:info).once.with(
      %r{After LHC response for request <\d+> GET http://local.ch at \d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\+\d{2}:\d{2} Time=0ms URL=http://local.ch:80/}
    )
  end


  context 'source' do
    let(:source) { '/Users/Sebastian/LHC/test.rb' }

    it 'does log the source if provided as option' do
      LHC.get('http://local.ch', source: source)
      expect(logger).to have_received(:info).once.with(
        %r{Before LHC request <\d+> GET http://local.ch at \d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\+\d{2}:\d{2} Params={} Headers={.*?} \nCalled from #{source}}
      )
      expect(logger).to have_received(:info).once.with(
        %r{After LHC response for request <\d+> GET http://local.ch at \d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\+\d{2}:\d{2} Time=0ms URL=http://local.ch:80/ \nCalled from #{source}}
      )
    end
  end

  context 'sensitive data' do
    before :each do
      LHC.config.scrubs[:params] << 'api_key'
      LHC.config.scrubs[:headers] << 'private_key'
      LHC.get('http://local.ch', params: { api_key: '123-abc' }, headers: { private_key: 'abc-123' })
    end

    it 'does log not log sensitive params information before every request made with LHC' do
      expect(logger).to have_received(:info).once.with(
        a_string_including('Params={:api_key=>"[FILTERED]"}')
      )
    end

    it 'does log not log sensitive headers information before every request made with LHC' do
      expect(logger).to have_received(:info).once.with(
        a_string_including(':private_key=>"[FILTERED]"')
      )
    end
  end
end
