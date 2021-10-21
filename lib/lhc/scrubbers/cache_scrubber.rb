# frozen_string_literal: true

class LHC::CacheScrubber < LHC::Scrubber
  def initialize(data)
    super(data)
    scrub_cache_options!
  end

  private

  def scrub_cache_options!
    return if scrubbed.blank?
    return if scrub_elements.blank?

    scrub_cache_key!
  end

  # TODO test this
  def scrub_cache_key!
    return if scrubbed[:key].blank?

    scrub_elements.each do |scrub_element|
      value = scrubbed[:key].match(/:#{scrub_element}=>"(.*?)"/)[-1]
      scrubbed[:key].gsub!(value, SCRUB_DISPLAY)
    end
  end

  def scrub_elements
    # The cache key includes the whole request url and params are added
    # to the request url so we need to scrub those params from the cache key.
    LHC.config.scrubs[:params]
  end
end
