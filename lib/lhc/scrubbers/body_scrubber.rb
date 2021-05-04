# frozen_string_literal: true

class LHC::BodyScrubber < LHC::Scrubber
  def initialize(data)
    super(data)
    parse!
    scrub!
  end

  private

  def scrub_elements
    LHC.config.scrubs[:body]
  end

  def parse!
    return if scrubbed.nil?
    return if scrubbed.is_a?(Hash)
    return if scrubbed.is_a?(Array)

    if scrubbed.is_a?(String)
      json = scrubbed
    else
      json = scrubbed.to_json
    end

    parsed = JSON.parse(json)
    self.scrubbed = parsed if parsed.is_a?(Hash) || parsed.is_a?(Array)
  end
end
