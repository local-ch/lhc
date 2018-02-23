module ZipkinTracer
  class TraceContainer
    attr_reader :trace_id, :parent_id, :span_id, :sampled, :flags
    class << self
      attr_accessor :current

      def setup_mock(trace_id:, parent_id:, span_id:, sampled:, flags:)
        @current = new(trace_id: trace_id, parent_id: parent_id, span_id: span_id, sampled: sampled, flags: flags)
      end

      def with_trace_id(trace_id)
        yield trace_id
      end
    end

    def initialize(trace_id:, parent_id:, span_id:, sampled:, flags:)
      @trace_id = trace_id
      @parent_id = parent_id
      @span_id = span_id
      @sampled = sampled
      @flags = flags
    end
  end

  class TraceGenerator
    def next_trace_id
      TraceId.new
    end
  end

  class TraceId
    def trace_id
      'trace_id'
    end
    def parent_id
      'parent_id'
    end
    def span_id
      'span_id'
    end
    def sampled
      'sampled'
    end
    def flags
      'flags'
    end
    def sampled?
      true
    end
  end

  class Span
    def record_tag(*)
    end
    def record(*)
    end
  end
end

module Trace
  def self.default_endpoint
    Endpoint.new
  end
  def self.tracer
    Tracer.new
  end

  class Tracer
    def start_span(*)
      return ZipkinTracer::Span.new
    end

    def end_span(*)
      return ZipkinTracer::Span.new
    end
  end

  class Annotation
    CLIENT_SEND = 'client_send'.freeze
    CLIENT_RECV = 'client_recv'.freeze
  end
  class BinaryAnnotation
    PATH = 'path'.freeze
    SERVER_ADDRESS = 'server_address'.freeze
    STATUS = 'status'.freeze
    ERROR = 'error'.freeze
    class Type
      STRING = 'string'.freeze
      BOOL = 'bool'.freeze
    end
  end
  class Endpoint
    class << self
      def remote_endpoint(*)
        new()
      end
    end
    def ip_format
      'ipv4'
    end
  end
end
