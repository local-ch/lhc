class LHC::Zipkin < LHC::Interceptor
  def before_request
    return unless dependencies?
    ZipkinTracer::TraceContainer.with_trace_id(trace_id) do
      B3_HEADERS.each { |method, header| request.headers[header] = trace_id.send(method).to_s }
      start_trace! if ::Trace.tracer && trace_id.sampled?
    end
  end

  def after_response
    return unless dependencies?
    end_trace!
  end

  private

  def start_trace!
    record_path
    record_remote_endpoint
    record_local_endpoint
  end

  def end_trace!
    record_status
    record_error if !response.success?
    record_end
  end

  B3_HEADERS = {
    trace_id: 'X-B3-TraceId'.freeze,
    parent_id: 'X-B3-ParentSpanId'.freeze,
    span_id: 'X-B3-SpanId'.freeze,
    sampled: 'X-B3-Sampled'.freeze,
    flags: 'X-B3-Flags'.freeze
  }.freeze

  TRUE = '1'.freeze # true in binary annotation

  def trace_id
    @trace_id ||= ZipkinTracer::TraceGenerator.new.next_trace_id
  end

  def span
    @span ||= ::Trace.tracer.start_span(trace_id, url.path)
  end

  def url
    @url ||= URI(request.raw.url)
  end

  def status
    @status ||= response.code.to_s
  end

  def service_name
    @service_name ||= url.host
  end

  def record_local_endpoint
    span.record(::Trace::Annotation::CLIENT_SEND, local_endpoint)
  end

  def record_remote_endpoint
    span.record_tag(::Trace::BinaryAnnotation::SERVER_ADDRESS, TRUE, ::Trace::BinaryAnnotation::Type::BOOL, remote_endpoint)
  end

  def record_path
    span.record_tag(::Trace::BinaryAnnotation::PATH, url.path, ::Trace::BinaryAnnotation::Type::STRING, local_endpoint)
  end

  def record_end
    span.record(::Trace::Annotation::CLIENT_RECV, local_endpoint)
    ::Trace.tracer.end_span(span)
  end

  def record_error
    span.record_tag(::Trace::BinaryAnnotation::ERROR, status, ::Trace::BinaryAnnotation::Type::STRING, local_endpoint)
  end

  def record_status
    span.record_tag(::Trace::BinaryAnnotation::STATUS, status, ::Trace::BinaryAnnotation::Type::STRING, local_endpoint)
  end

  def local_endpoint
    @local_endpoint ||= ::Trace.default_endpoint
  end

  def remote_endpoint
    @remote_endpoint ||= ::Trace::Endpoint.remote_endpoint(url, service_name, local_endpoint.ip_format)
  end

  def dependencies?
    (
      defined?(ZipkinTracer::TraceContainer) &&
      ZipkinTracer::TraceContainer.current &&
      defined?(Trace)
    ) || warn('[WARNING] Zipkin interceptor is enabled but dependencies are not found. See: https://github.com/local-ch/lhc/blob/master/docs/interceptors/zipkin.md')
  end
end
