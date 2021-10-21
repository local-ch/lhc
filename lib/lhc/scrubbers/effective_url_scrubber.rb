# frozen_string_literal: true

# TODO test this!!!
class LHC::EffectiveUrlScrubber < LHC::Scrubber
  def initialize(data)
    super(data)
    scrub_effective_url_options!
  end

  private

  def scrub_effective_url_options!
    return if scrubbed.blank?
    return if scrub_elements.blank?

    scrub_effective_url!
  end

  # TODO test this
  def scrub_effective_url!
    return if scrubbed.blank?

    scrub_elements.each do |scrub_element|
      # TODO maybe it makes sense to partse it as URL and then replace stuff
      # and then make a string again isntead of using regex
      value = scrubbed.match(/#{scrub_element}=(.*?)(&|$)/)[1]
      scrubbed.gsub!(value, SCRUB_DISPLAY)
    end
  end

  def scrub_elements
    # The effective url includes the params of the request
    # so we need to scrub those params from the effective url.
    LHC.config.scrubs[:params]
  end
end
