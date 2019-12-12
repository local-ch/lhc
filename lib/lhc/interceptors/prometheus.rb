# frozen_string_literal: true

class LHC::Prometheus < LHC::Interceptor
  include ActiveSupport::Configurable

  config_accessor :client, :namespace

  REQUEST_COUNTER_KEY = :lhc_requests
  REQUEST_HISTOGRAM_KEY = :lhc_request_seconds

  class << self
    attr_accessor :registered
  end

  def initialize(request)
    super(request)
    return if LHC::Prometheus.registered || LHC::Prometheus.client.blank?
    
    begin
      LHC::Prometheus.client.registry.counter(LHC::Prometheus::REQUEST_COUNTER_KEY, 'Counter of all LHC requests.')
      LHC::Prometheus.client.registry.histogram(LHC::Prometheus::REQUEST_HISTOGRAM_KEY, 'Request timings for all LHC requests in seconds.')
    rescue Prometheus::Client::Registry::AlreadyRegisteredError => e
      Rails.logger.error(e) if defined?(Rails)
    ensure
      LHC::Prometheus.registered = true
    end
  end

  def after_response
    return if !LHC::Prometheus.registered || LHC::Prometheus.client.blank?

    host = URI.parse(request.url).host

    LHC::Prometheus.client.registry
      .get(LHC::Prometheus::REQUEST_COUNTER_KEY)
      .increment(
        code: response.code,
        success: response.success?,
        timeout: response.timeout?,
        host: host,
        app: LHC::Prometheus.namespace
      )

    LHC::Prometheus.client.registry
      .get(LHC::Prometheus::REQUEST_HISTOGRAM_KEY)
      .observe({
                 host: host,
                 app: LHC::Prometheus.namespace
               }, response.time)
  end
end
