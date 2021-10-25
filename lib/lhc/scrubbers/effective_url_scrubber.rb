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
      uri = LocalUri::URI.new(scrubbed)
      self.scrubbed = CGI.unescape(uri.query.merge(scrub_element => SCRUB_DISPLAY).to_s)
    end
  end

  def scrub_elements
    # The effective url includes the params of the request
    # so we need to scrub those params from the effective url.
    LHC.config.scrubs[:params]
  end
end
