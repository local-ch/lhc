class LHC::Caching < LHC::Interceptor
  include ActiveSupport::Configurable

  config_accessor :cache, :logger

  CACHE_VERSION = '1'

  # Options forwarded to the cache
  FORWARDED_OPTIONS = [:expires_in, :race_condition_ttl]

  def before_request(request)
    return unless request.options[:cache]
    @options = request.options[:cache]
    @options = {} if @options == true
    map_deprecated_options(request.options)
    @cache = @options.fetch(:use, cache)
    return unless @cache
    return unless cached_method?(request.method, @options[:methods])
    cached_response_data = @cache.fetch(key(request))
    return unless cached_response_data
    logger.info "Served from cache: #{key(request)}" if logger
    from_cache(request, cached_response_data)
  end

  def after_response(response)
    return unless @cache
    request = response.request
    return unless cached_method?(request.method, @options[:methods])
    return if !@options || !response.success?
    @cache.write(key(request), to_cache(response), options(@options))
  end

  private

  def map_deprecated_options(request_options)
    old_keys = request_options.keys.select { |k|k =~ /cache_.*/ }
    old_keys.each do |old_key|
      new_key = old_key.to_s.gsub('cache_', '').to_sym
      @options[new_key] = request_options[old_key]
    end

    unless old_keys.empty?
      deprecation_warning = "Cache options have changed! #{old_keys.join(', ')} are deprecated and will be removed in future versions."
      ActiveSupport::Deprecation.warn(deprecation_warning)
    end
  end

  # converts json we read from the cache to an LHC::Response object
  def from_cache(request, data)
    raw = Typhoeus::Response.new(data)
    response = LHC::Response.new(raw, request, from_cache: true)
    request.response = response
    response
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
    # in a test scenario typhoeus uses mocks and not return_code to determine 'success?'
    data[:mock] = response.mock
    data
  end

  def key(request)
    key = @options[:key]
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
    input.each_with_object({}) do |(key, value), result|
      result[key] = value if key.in? FORWARDED_OPTIONS
      result
    end
  end
end
