# frozen_string_literal: true

class LHC::AuthScrubber < LHC::Scrubber
  def initialize(data)
    super(data)
    scrub_auth_options!
  end

  # TODO For README: if it is not a standard validation, then simply scrub the whole Authorization header like this:
  # config.scrubs[:headers] << 'Authorization'
  # Note that now all Authorization headers in all request is filtered

  private

  def scrub_auth_options!
    return if scrubbed.blank?
    return if scrub_auth_elements.blank?

    scrub_basic_auth_options! if scrub_auth_elements.include?(:basic)
    scrub_bearer_auth_options! if scrub_auth_elements.include?(:bearer)
  end

  def scrub_basic_auth_options!
    return if scrubbed[:basic].blank?

    scrubbed[:basic][:username] = SCRUB_DISPLAY
    scrubbed[:basic][:password] = SCRUB_DISPLAY
    scrubbed[:basic][:base_64_encoded_credentials] = SCRUB_DISPLAY
  end

  def scrub_bearer_auth_options!
    return if scrubbed[:bearer].blank?

    scrubbed[:bearer_token] = SCRUB_DISPLAY
  end
end
