# frozen_string_literal: true

class LHC::Prometheus < LHC::Interceptor
  include ActiveSupport::Configurable

  config_accessor :client, :namespace

  class << self
    attr_accessor :registered
  end

  def self.request_key
    [LHC::Prometheus.namespace, 'lhc_requests'].join('_').to_sym
  end

  def self.times_key
    [LHC::Prometheus.namespace, 'lhc_request_seconds'].join('_').to_sym
  end

  def self.deprecated_times_key
    [LHC::Prometheus.namespace, 'lhc_times'].join('_').to_sym
  end

  def initialize(request)
    super(request)
    return if LHC::Prometheus.registered || LHC::Prometheus.client.blank?
    LHC::Prometheus.client.registry.counter(LHC::Prometheus.request_key, 'Counter of all LHC requests.')
    LHC::Prometheus.client.registry.histogram(LHC::Prometheus.deprecated_times_key, 'Times for all LHC requests (Deprecated)')
    LHC::Prometheus.client.registry.histogram(LHC::Prometheus.times_key, 'Request timings for all LHC requests in seconds.')
    LHC::Prometheus.registered = true
  end

  def after_response
    return if !LHC::Prometheus.registered || LHC::Prometheus.client.blank?

    host = URI.parse(request.url).host

    LHC::Prometheus.client.registry
      .get(LHC::Prometheus.request_key)
      .increment(
        code: response.code,
        success: response.success?,
        timeout: response.timeout?,
        host: host
      )

    LHC::Prometheus.client.registry
      .get(LHC::Prometheus.deprecated_times_key)
      .observe({}, response.time_ms)

    LHC::Prometheus.client.registry
      .get(LHC::Prometheus.times_key)
      .observe({ host: host }, response.time)
  end
end
