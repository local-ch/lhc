# frozen_string_literal: true

require 'uri'
require 'active_support/core_ext/object/deep_dup'
require 'lhc/concerns/lhc/request/user_agent_concern'

# The request is doing an http-request using typhoeus.
# It provides functionalities to access and alter request data
# and it communicates with interceptors.
class LHC::Request
  include UserAgentConcern

  TYPHOEUS_OPTIONS ||= [:params, :method, :body, :headers, :follow_location, :params_encoding]

  # TODO are they needed to be withing this attr_accessor?
  attr_accessor :response,
                :options,
                :raw,
                :format,
                :scrubbed_params,
                :scrubbed_headers,
                :scrubbed_options,
                :error_handler,
                :errors_ignored,
                :source

  def initialize(options, self_executing = true)
    self.errors_ignored = (options.fetch(:ignore, []) || []).to_a.compact
    self.source = options&.dig(:source)
    self.options = format!(options.deep_dup || {})
    self.error_handler = options.delete :rescue
    use_configured_endpoint!
    generate_url_from_template!
    self.interceptors = LHC::Interceptors.new(self)
    interceptors.intercept(:before_raw_request)
    self.raw = create_request
    interceptors.intercept(:before_request)
    #self.scrubbed_params = LHC::ParamsScrubber.new(params.deep_dup).scrubbed_data
    #self.scrubbed_headers = LHC::HeadersScrubber.new(headers.deep_dup, self.options[:auth]).scrubbed_data
    #self.scrubbed_options = LHC::OptionsScrubber.new(self.options.deep_dup).scrubbed_data
    
    
    # self.scrubbed_params = params.deep_dup
    # self.scrubbed_headers = headers.deep_dup
    # self.scrubbed_options = self.options.deep_dup
    # scrub!
    if self_executing && !response
      run!
    elsif response
      on_complete(response)
    end
  end

  def scrubbed_params
    binding.pry
    LHC::ParamsScrubber.new(params.deep_dup).scrubbed
  end

  def scrubbed_headers
    LHC::HeadersScrubber.new(headers.deep_dup, options[:auth]).scrubbed
  end

  def scrubbed_options
    scrubbed_options = options.deep_dup
    scrubbed_options[:params] = LHC::ParamsScrubber.new(scrubbed_options[:params]).scrubbed
    scrubbed_options[:headers] = LHC::HeadersScrubber.new(scrubbed_options[:headers], scrubbed_options[:auth]).scrubbed
    scrubbed_options[:auth] = LHC::AuthScrubber.new(scrubbed_options[:auth]).scrubbed
    scrubbed_options[:body] = LHC::BodyScrubber.new(scrubbed_options[:body]).scrubbed
    scrubbed_options
  end












  def url
    raw.base_url || options[:url]
  end

  def method
    (raw.options[:method] || options[:method] || :get).to_sym
  end

  def headers
    raw.options.fetch(:headers, nil) || raw.options[:headers] = {}
  end

  def params
    raw.options.fetch(:params, nil) || raw.options[:params] = {}
  end

  def error_ignored?
    ignore_error?
  end

  def run!
    raw.run
  end

  private

  attr_accessor :interceptors

  def format!(options)
    self.format = options.delete(:format) || LHC::Formats::JSON.new
    format.format_options(options)
  end

  def optionally_encoded_url(options)
    return options[:url] unless options.fetch(:url_encoding, true)
    encode_url(options[:url])
  end

  def create_request
    request = Typhoeus::Request.new(
      optionally_encoded_url(options),
      translate_body(typhoeusize(options))
    )
    request.on_headers do
      interceptors.intercept(:after_request)
      interceptors.intercept(:before_response)
    end
    request.on_complete { |response| on_complete(response) }
    request
  end

  def translate_body(options)
    return options if options.fetch(:body, nil).blank?
    options[:body] = format.to_body(options[:body])
    options
  end

  def encode_url(url)
    return url if url.nil?
    Addressable::URI.escape(url)
  end

  def typhoeusize(options)
    options = options.deep_dup
    easy = Ethon::Easy.new
    options.delete(:url)
    options.each do |key, _v|
      next if TYPHOEUS_OPTIONS.include? key
      method = "#{key}="
      options.delete key unless easy.respond_to?(method)
    end
    options
  end

  # Get configured endpoint and use it for doing the request.
  # Explicit request options are overriding configured options.
  def use_configured_endpoint!
    endpoint = LHC.config.endpoints[options[:url]]
    return unless endpoint
    # explicit options override endpoint options
    new_options = endpoint.options.deep_merge(options)
    # set new options
    self.options = new_options
    options[:url] = endpoint.url
  end

  # Generates URL from a URL template
  def generate_url_from_template!
    endpoint = LHC::Endpoint.new(options[:url])
    params =
      if format && options[:body].present? && options[:body].respond_to?(:as_json) && options[:body].as_json.is_a?(Hash)
        options[:body].as_json.merge(options[:params] || {}).deep_symbolize_keys
      else
        options[:params]
      end
    options[:url] = endpoint.compile(params)
    endpoint.remove_interpolated_params!(options[:params])
  end

  def on_complete(response)
    self.response = response.is_a?(LHC::Response) ? response : LHC::Response.new(response, self)
    interceptors.intercept(:after_response)
    handle_error(self.response) unless self.response.success?
  end

  def handle_error(response)
    return if ignore_error?
    throw_error(response) unless error_handler
    response.body_replacement = error_handler.call(response)
  end

  def ignore_error?
    @ignore_error ||= begin
      errors_ignored.detect do |ignored_error|
        error <= ignored_error
      end.present?
    end
  end

  def error
    @error ||= LHC::Error.find(response)
  end

  def throw_error(response)
    # TODO here it also logs sensitive data
    raise error.new(error, response)
  end

  # def scrub!
  #   return if LHC.config.scrubs.blank?

  #   scrub_auth!(scrubbed_headers)
  #   scrub_auth!(scrubbed_options[:headers])

  #   xscrub!(scrubbed_params, LHC.config.scrubs[:params])
  #   xscrub!(scrubbed_options[:params], LHC.config.scrubs[:params])

  #   xscrub!(scrubbed_headers, LHC.config.scrubs[:headers])
  #   xscrub!(scrubbed_options[:headers], LHC.config.scrubs[:headers])

  #   xscrub!(scrubbed_options[:body], LHC.config.scrubs[:body])
  # end

  # def scrub_auth!(headers)
  #   return if LHC.config.scrubs[:auth].blank?
  #   scrub_basic_authentication!(headers) if LHC.config.scrubs.dig(:auth).include?(:basic)
  #   scrub_bearer_authentication!(headers) if LHC.config.scrubs.dig(:auth).include?(:bearer)
  # end

  # # TODO rename
  # def xscrub!(data, elements_to_be_scrubbed_in_data)
  #   return if elements_to_be_scrubbed_in_data.blank?
  #   return if data.blank?
  #   binding.pry

  #   elements_to_be_scrubbed_in_data.each do |element_to_be_scrubbed_in_data|
  #     binding.pry
  #     if data.has_key?(element_to_be_scrubbed_in_data.to_s)
  #       key = element_to_be_scrubbed_in_data.to_s
  #     elsif data.has_key?(element_to_be_scrubbed_in_data.to_sym)
  #       key = element_to_be_scrubbed_in_data.to_sym
  #     end
  #     next if key.blank?
  #     data[key] = '[FILTERED]' # TODO create constante
  #   end
  # end

  # def scrub_basic_authentication!(headers)
  #   return if options.dig(:auth, :basic).blank? # TODO is it really options here?
  #   return if headers['Authorization'].blank?

  #   headers['Authorization'] = headers['Authorization'].gsub(options[:auth][:basic][:base_64_encoded_credentials], '[FILTERED]')
  # end

  # def scrub_bearer_authentication!(headers)
  #   return if options.dig(:auth, :bearer).blank? # TODO is it really options here?
  #   return if headers['Authorization'].blank?

  #   headers['Authorization'] = headers['Authorization'].gsub(options[:auth][:bearer_token], '[FILTERED]')
  # end
end
