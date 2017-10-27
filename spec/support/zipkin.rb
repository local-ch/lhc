module ZipkinTracer
  class TraceContainer
    attr_reader :trace_id, :parent_id, :span_id, :sampled, :flags
    class << self
      attr_accessor :current

      def setup_mock(trace_id:, parent_id:, span_id:, sampled:, flags:)
        @current = new(trace_id: trace_id, parent_id: parent_id, span_id: span_id, sampled: sampled, flags: flags)
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
end
