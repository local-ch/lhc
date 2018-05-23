require 'rails_helper'

describe LHC::Logging do
  let(:logger) { spy('logger') }

  before(:each) do
    LHC.config.interceptors = [LHC::Logging]
    LHC::Logging.logger = logger
  end

  it 'does log information before and after every request made with LHC' do
    stub_request(:get, 'http://local.ch').to_return(status: 200)
    LHC.get('http://local.ch')
    expect(logger).to have_received(:info).once.with(
      %r{Before LHC request<\d+> GET http://local.ch at \d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\+\d{2}:\d{2} Params={} Headers={.*?}}
    )
    expect(logger).to have_received(:info).once.with(
      %r{After LHC response for request<\d+> GET http://local.ch at \d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\+\d{2}:\d{2} Time=0ms URL=http://local.ch:80/}
    )
  end
end
