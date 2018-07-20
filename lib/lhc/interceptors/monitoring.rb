class LHC::Monitoring < LHC::Interceptor

  # Options forwarded to the monitoring
  FORWARDED_OPTIONS = {
    monitoring_key: :key
  }

  include ActiveSupport::Configurable

  config_accessor :statsd, :env

  def before_request
    return unless statsd
    LHC::Monitoring.statsd.count("#{key(request)}.before_request", 1)
  end

  def after_request
    return unless statsd
    LHC::Monitoring.statsd.count("#{key(request)}.count", 1)
    LHC::Monitoring.statsd.count("#{key(request)}.after_request", 1)
  end

  def after_response
    return unless statsd
    key = key(response)
    LHC::Monitoring.statsd.timing("#{key}.time", response.time) if response.success?
    key += response.timeout? ? '.timeout' : ".#{response.code}"
    LHC::Monitoring.statsd.count(key, 1)
  end

  private

  def key(target)
    request = target.is_a?(LHC::Request) ? target : target.request
    key = options(request.options)[:key]
    return key if key.present?

    url = sanitize_url(request.url)
    key = [
      'lhc',
      Rails.application.class.parent_name.underscore,
      LHC::Monitoring.env || Rails.env,
      URI.parse(url).host.gsub(/\./, '_'),
      request.method
    ]
    key.join('.')
  end

  def sanitize_url(url)
    return url if url.match(%r{https?://})
    "http://#{url}"
  end

  def options(input = {})
    options = {}
    FORWARDED_OPTIONS.each do |k, v|
      options[v] = input[k] if input.key?(k)
    end
    options
  end
end
