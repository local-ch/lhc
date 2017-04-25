class LHC::Caching < LHC::Interceptor
  include ActiveSupport::Configurable

  config_accessor :cache, :logger

  CACHE_VERSION = '1'

  # Options forwarded to the cache
  FORWARDED_OPTIONS = {
    cache_expires_in: :expires_in,
    cache_race_condition_ttl: :race_condition_ttl
  }

  def before_request(request)
    return unless cache
    return unless request.options[:cache]
    return unless cached_method?(request.method, request.options[:cache_methods])
    cached_response_data = cache.fetch(key(request))
    return unless cached_response_data
    logger.info "Served from cache: #{key(request)}" if logger
    from_cache(request, cached_response_data)
  end

  def after_response(response)
    return unless cache
    request = response.request
    return unless cached_method?(request.method, request.options[:cache_methods])
    return if !request.options[:cache] || !response.success?
    cache.write(key(request), to_cache(response), options(request.options))
  end

  private

  # converts json we read from the cache to an LHC::Response object
  def from_cache(request, data)
    raw = Typhoeus::Response.new(data)
    request.response = LHC::Response.new(raw, request)
  end

  # converts a LHC::Response object to json, we store in the cache
  def to_cache(response)
    data = {}
    data[:body] = response.body
    data[:code] = response.code
    # convert into a actual hash because the typhoeus headers object breaks marshaling
    data[:headers] = response.headers ? Hash[response.headers] : response.headers
    # return_code is quite important as Typhoeus relies on it in order to determin 'success?'
    data[:return_code] = response.options[:return_code]
    data
  end

  def key(request)
    key = request.options[:cache_key]
    unless key
      key = "#{request.method.upcase} #{request.url}"
      key += "?#{request.params.to_query}" unless request.params.blank?
    end
    "LHC_CACHE(v#{CACHE_VERSION}): #{key}"
  end

  # Checks if the provided method should be cached
  # in regards of the provided options.
  def cached_method?(method, cached_methods)
    (cached_methods || [:get]).include?(method)
  end

  def options(input = {})
    options = {}
    FORWARDED_OPTIONS.each do |k, v|
      options[v] = input[k] if input.key?(k)
    end
    options
  end
end
