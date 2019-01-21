# frozen_string_literal: true

class LHC::Caching < LHC::Interceptor
  include ActiveSupport::Configurable

  config_accessor :cache, :logger

  CACHE_VERSION = '1'

  # Options forwarded to the cache
  FORWARDED_OPTIONS = [:expires_in, :race_condition_ttl]

  def before_request
    return unless cache?(request)
    deprecation_warning(request.options)
    options = options(request.options)
    key = key(request, options[:key])
    response_data = cache_for(options).fetch(key)
    return unless response_data
    logger&.info "Served from cache: #{key}"
    from_cache(request, response_data)
  end

  def after_response
    return unless response.success?
    request = response.request
    return unless cache?(request)
    options = options(request.options)
    cache_for(options).write(
      key(request, options[:key]),
      to_cache(response),
      cache_options(options)
    )
  end

  private

  # return the cache for the given options
  def cache_for(options)
    options.fetch(:use, cache)
  end

  # do we even need to bother with this interceptor?
  # based on the options, this method will
  # return false if this interceptor cannot work
  def cache?(request)
    return false unless request.options[:cache]
    options = options(request.options)
    cache_for(options) &&
      cached_method?(request.method, options[:methods])
  end

  # returns the request_options
  # will map deprecated options to the new format
  def options(request_options)
    options = (request_options[:cache] == true) ? {} : request_options[:cache].dup
    map_deprecated_options!(request_options, options)
    options
  end

  # maps `cache_key` -> `key`, `cache_expires_in` -> `expires_in` and so on
  def map_deprecated_options!(request_options, options)
    deprecated_keys(request_options).each do |deprecated_key|
      new_key = deprecated_key.to_s.gsub(/^cache_/, '').to_sym
      options[new_key] = request_options[deprecated_key]
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

  def key(request, key)
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

  # extracts the options that should be forwarded to
  # the cache
  def cache_options(input = {})
    input.each_with_object({}) do |(key, value), result|
      result[key] = value if key.in? FORWARDED_OPTIONS
      result
    end
  end

  # grabs the deprecated keys from the request options
  def deprecated_keys(request_options)
    request_options.keys.select { |k| k =~ /^cache_.*/ }.sort
  end

  # emits a deprecation warning if necessary
  def deprecation_warning(request_options)
    unless deprecated_keys(request_options).empty?
      ActiveSupport::Deprecation.warn(
        "Cache options have changed! #{deprecated_keys(request_options).join(', ')} are deprecated and will be removed in future versions."
      )
    end
  end
end
