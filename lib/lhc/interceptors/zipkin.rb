class LHC::Zipkin < LHC::Interceptor

  def before_request
    return unless dependencies?
    trace_id = ZipkinTracer::TraceGenerator.new.next_trace_id
    ZipkinTracer::TraceContainer.with_trace_id(trace_id) do
      b3_headers.each do |method, header|
        request.headers[header] = trace_id.send(method).to_s
      end
      trace!(request, trace_id) if ::Trace.tracer && trace_id.sampled?
    end
  end

  def after_response
    return unless dependencies?
    span = response.request.interceptor_environment[:zipkin_span]
    if span
      record_response_tags(span, response)
    end
    span.record(::Trace::Annotation::CLIENT_RECV, local_endpoint)
    ::Trace.tracer.end_span(span)
  end

  private

  SERVER_ADDRESS_SPECIAL_VALUE = '1'.freeze

  def b3_headers
    {
      trace_id: 'X-B3-TraceId',
      parent_id: 'X-B3-ParentSpanId',
      span_id: 'X-B3-SpanId',
      sampled: 'X-B3-Sampled',
      flags: 'X-B3-Flags'
    }
  end

  def trace!(request, trace_id)
    url = URI(request.raw.url)
    service_name = url.host
    span = ::Trace.tracer.start_span(trace_id, url.path)
    # annotate with method (GET/POST/etc.) and uri path
    span.record_tag(::Trace::BinaryAnnotation::PATH, url.path, ::Trace::BinaryAnnotation::Type::STRING, local_endpoint)
    span.record_tag(::Trace::BinaryAnnotation::SERVER_ADDRESS, SERVER_ADDRESS_SPECIAL_VALUE, ::Trace::BinaryAnnotation::Type::BOOL, remote_endpoint(url, service_name))
    span.record(::Trace::Annotation::CLIENT_SEND, local_endpoint)
    # store the span in the datum hash so it can be used in the response_call
    request.interceptor_environment[:zipkin_span] = span
  # rubocop:disable Lint/HandleExceptions
  rescue ArgumentError, URI::Error
    # Ignore URI errors, don't trace if there is no URI
  end
  # rubocop:enable Lint/HandleExceptions

  def local_endpoint
    # The rack middleware set this up for us.
    ::Trace.default_endpoint
  end

  def remote_endpoint(url, service_name)
    # The endpoint we are calling.
    ::Trace::Endpoint.remote_endpoint(url, service_name, local_endpoint.ip_format)
  end

  def record_response_tags(span, response)
    status = response.code.to_s
    span.record_tag(::Trace::BinaryAnnotation::STATUS, status, ::Trace::BinaryAnnotation::Type::STRING, local_endpoint)
    if !response.success?
      span.record_tag(::Trace::BinaryAnnotation::ERROR, status, ::Trace::BinaryAnnotation::Type::STRING, local_endpoint)
    end
  end

  def dependencies?
    (
      defined?(ZipkinTracer::TraceContainer) &&
      ZipkinTracer::TraceContainer.current &&
      defined?(Trace)
    ) || warn('[WARNING] Zipkin interceptor is enabled but dependencies are not found. See: https://github.com/local-ch/lhc/blob/master/docs/interceptors/zipkin.md')
  end
end
