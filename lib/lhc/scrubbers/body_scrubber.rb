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

  # TODO is this the right thing to do? Shall we parse custom data?
  def parse!
    return if scrubbed.nil?
    return if scrubbed.is_a?(Hash)

    if scrubbed.is_a?(String)
      json = scrubbed
    else
      json = scrubbed.to_json
    end

    parsed = JSON.parse(json)
    self.scrubbed = parsed if parsed.is_a?(Hash)
  end
end
