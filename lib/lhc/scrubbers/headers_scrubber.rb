# frozen_string_literal: true

class LHC::HeadersScrubber < LHC::Scrubber
  def initialize(data, auth_options)
    super(data)
    @auth_options = auth_options
    scrub!
    scrub_auth_headers!
  end

  private

  attr_reader :auth_options

  def scrub_elements
    LHC.config.scrubs[:headers]
  end

  def scrub_auth_headers!
    return if scrub_auth_elements.blank?
    return if auth_options.blank?

    scrub_basic_authentication_headers! if scrub_auth_elements.include?(:basic)
    scrub_bearer_authentication_headers! if scrub_auth_elements.include?(:bearer)
  end

  def scrub_basic_authentication_headers!
    return if !scrub_basic_authentication_headers?

    scrubbed['Authorization'].gsub!(auth_options[:basic][:base_64_encoded_credentials], SCRUB_DISPLAY)
  end

  def scrub_bearer_authentication_headers!
    return if !scrub_bearer_authentication_headers?

    scrubbed['Authorization'].gsub!(auth_options[:bearer_token], SCRUB_DISPLAY)
  end

  def scrub_basic_authentication_headers?
    auth_options[:basic].present? &&
      scrubbed['Authorization'].present? &&
      scrubbed['Authorization'].include?(auth_options[:basic][:base_64_encoded_credentials])
  end

  def scrub_bearer_authentication_headers?
    auth_options[:bearer].present? &&
      auth_options[:bearer_token] &&
      scrubbed['Authorization'].present? &&
      scrubbed['Authorization'].include?(auth_options[:bearer_token])
  end
end
