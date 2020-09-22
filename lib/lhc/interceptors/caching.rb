# frozen_string_literal: true

class LHC::Caching < LHC::Interceptor
  include ActiveSupport::Configurable

  config_accessor :cache, :central

  # to control cache invalidation across all applications in case of
  # breaking changes within this inteceptor
  # that do not lead to cache invalidation otherwise
  CACHE_VERSION = '1'

  # Options forwarded to the cache
  FORWARDED_OPTIONS = [:expires_in, :race_condition_ttl]

  class MultilevelCache

    def initialize(central: nil, local: nil)
      @central = central
      @local = local
    end

    def fetch(key)
      central_response = @central[:read].fetch(key) if @central && @central[:read].present?
      if central_response
        puts %Q{[LHC] served from central cache: "#{key}"}
        return central_response
      end
      local_response = @local.fetch(key) if @local
      if local_response
        puts %Q{[LHC] served from local cache: "#{key}"}
        return local_response
      end
    end

    def write(key, content, options)
      @central[:write].write(key, content, options) if @central && @central[:write].present?
      @local.write(key, content, options) if @local.present?
    end
  end

  def before_request
    return unless cache?(request)
    key = key(request, options[:key])
    response_data = multilevel_cache.fetch(key)
    return unless response_data
    from_cache(request, response_data)
  end

  def after_response
    return unless response.success?
    return unless cache?(request)
    multilevel_cache.write(
      key(request, options[:key]),
      to_cache(response),
      cache_options
    )
  end

  private

  # performs read/write (fetch/write) on all configured cache levels (e.g. local & central)
  def multilevel_cache
    MultilevelCache.new(
      central: central_cache,
      local: local_cache
    )
  end

  # returns the local cache either configured for entire LHC
  # or configured locally for that particular request
  def local_cache
    options.fetch(:use, cache)
  end

  def central_cache
    return nil if central.blank? || (central[:read].blank? && central[:write].blank?)
    {}.tap do |options|
      options[:read] = ActiveSupport::Cache::RedisCacheStore.new(url: central[:read]) if central[:read].present?
      options[:write] = ActiveSupport::Cache::RedisCacheStore.new(url: central[:write]) if central[:write].present?
    end
  end

  # do we even need to bother with this interceptor?
  # based on the options, this method will
  # return false if this interceptor cannot work
  def cache?(request)
    return false unless request.options[:cache]
    (local_cache || central_cache) &&
      cached_method?(request.method, options[:methods])
  end

  def options
    options = (request.options[:cache] == true) ? {} : request.options[:cache].dup
    options
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
  def cache_options
    options.each_with_object({}) do |(key, value), result|
      result[key] = value if key.in? FORWARDED_OPTIONS
      result
    end
  end
end
