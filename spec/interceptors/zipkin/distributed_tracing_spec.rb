require 'rails_helper'

describe LHC::ZipkinDistributedTracing do
  before(:all) do
    # defined in spec/support/zipkin.rb
    ::ZipkinTracer::TraceContainer.setup_mock(
      trace_id: 'trace_id',
      parent_id: 'parent_id',
      span_id: 'span_id',
      sampled: 'sampled',
      flags: 'flags'
    )
  end

  before(:each) do
    LHC.config.interceptors = [described_class]
    LHC.config.endpoint(:local, 'http://local.ch')
    stub_request(:get, 'http://local.ch').to_return(status: 200, body: 'The Website')
  end

  it 'adds the proper X-B3 headers' do
    headers = LHC.get(:local).request.headers
    expect(headers['X-B3-TraceId']).to eq('trace_id')
    expect(headers['X-B3-ParentSpanId']).to eq('parent_id')
    expect(headers['X-B3-SpanId']).to eq('span_id')
    expect(headers['X-B3-Sampled']).to eq('sampled')
    expect(headers['X-B3-Flags']).to eq('flags')
  end
end
