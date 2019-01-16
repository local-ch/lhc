# frozen_string_literal: true

require 'rails_helper'

describe LHC::Zipkin do
  before(:each) do
    LHC.config.interceptors = [described_class]
    LHC.config.endpoint(:local, 'http://local.ch')
    stub_request(:get, 'http://local.ch').to_return(status: 200, body: 'The Website')
  end

  context 'with zipkin tracer integration' do
    before(:all) do
      ::ZipkinTracer::TraceContainer.setup_mock(
        trace_id: 'trace_id',
        parent_id: 'parent_id',
        span_id: 'span_id',
        sampled: true,
        flags: 'flags'
      )
    end

    it 'adds the proper X-B3 headers' do
      headers = LHC.get(:local).request.headers
      expect(headers['X-B3-TraceId']).to eq('trace_id')
      expect(headers['X-B3-ParentSpanId']).to eq('parent_id')
      expect(headers['X-B3-SpanId']).to eq('span_id')
      expect(headers['X-B3-Sampled']).to eq('true')
      expect(headers['X-B3-Flags']).to eq('flags')
    end
  end

  context 'wihtout zipkin integration' do
    before(:all) do
      TemporaryZipkinTracer = ::ZipkinTracer
      Object.send(:remove_const, :ZipkinTracer)
    end

    after(:all) do
      ::ZipkinTracer = TemporaryZipkinTracer
    end

    it 'adds the proper X-B3 headers' do
      headers = nil
      expect { headers = LHC.get(:local).request.headers }.not_to raise_error

      expect(headers['X-B3-TraceId']).to be_nil
      expect(headers['X-B3-ParentSpanId']).to be_nil
      expect(headers['X-B3-SpanId']).to be_nil
      expect(headers['X-B3-Sampled']).to be_nil
      expect(headers['X-B3-Flags']).to be_nil
    end
  end

  describe 'creating new spans' do
    context 'sampled? is false' do
      before(:all) do
        ::ZipkinTracer::TraceContainer.setup_mock(
          trace_id: 'trace_id',
          parent_id: 'parent_id',
          span_id: 'span_id',
          sampled: false,
          flags: 'flags'
        )
      end

      it 'adds the proper X-B3 headers' do
        headers = LHC.get(:local).request.headers
        expect(headers['X-B3-TraceId']).to eq('trace_id')
        expect(headers['X-B3-ParentSpanId']).to eq('parent_id')
        expect(headers['X-B3-SpanId']).to eq('span_id')
        expect(headers['X-B3-Sampled']).to eq('false')
        expect(headers['X-B3-Flags']).to eq('flags')
      end

      it 'does not register a new span' do
        # ensure no span was registered, by checking no call on span
        expect_any_instance_of(described_class).not_to receive(:span).and_call_original
        LHC.get(:local)
      end
    end

    context 'sampled? is true' do
      before(:all) do
        ::ZipkinTracer::TraceContainer.setup_mock(
          trace_id: 'trace_id',
          parent_id: 'parent_id',
          span_id: 'span_id',
          sampled: true,
          flags: 'flags'
        )
      end

      it 'adds the proper X-B3 headers' do
        headers = LHC.get(:local).request.headers
        expect(headers['X-B3-TraceId']).to eq('trace_id')
        expect(headers['X-B3-ParentSpanId']).to eq('parent_id')
        expect(headers['X-B3-SpanId']).to eq('span_id')
        expect(headers['X-B3-Sampled']).to eq('true')
        expect(headers['X-B3-Flags']).to eq('flags')
      end

      it 'does register a new span' do
        # ensure a span was registered, by checking call on span
        expect_any_instance_of(described_class).to receive(:span).at_least(:once).and_call_original
        LHC.get(:local)
      end
    end
  end
end
