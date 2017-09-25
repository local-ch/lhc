module LHC
  class PrometheusInterceptor < LHC::Interceptor
    def initialize
      Prometheus::Client.registry.counter(:web_weather_lhc_requests, 'Counter of all LHC requests.') if !Prometheus::Client.registry.exist?(:web_weather_lhc_requests)
      Prometheus::Client.registry.histogram(:web_weather_lhc_seconds, 'Times for all LHC requests.') if !Prometheus::Client.registry.exist?(:web_weather_lhc_seconds)
    end

    def after_response(response)
      Prometheus::Client.registry
        .get(:web_weather_lhc_requests).increment(code: response.code, success: response.success?, timeout: response.timeout?)
      Prometheus::Client.registry
        .get(:web_weather_lhc_seconds).observe({}, response.time / 1000.0)
    end
  end
end
