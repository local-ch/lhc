class LHC::ZipkinDistributedTracing < LHC::Interceptor

  def before_request(request)
    return unless defined?(ZipkinTracer::TraceContainer)
    container = ZipkinTracer::TraceContainer.current
    request.headers['X-B3-TraceId'] = container.trace_id.to_s
    request.headers['X-B3-ParentSpanId'] = container.parent_id.to_s if container.parent_id
    request.headers['X-B3-SpanId'] = container.span_id.to_s
    request.headers['X-B3-Sampled'] = container.sampled
    request.headers['X-B3-Flags'] = container.flags
  end
end
