# frozen_string_literal: true

class LHC::BodyScrubber < LHC::Scrubber
  def initialize(data)
    super(data)
    scrub!
  end

  private

  def scrub_elements
    LHC.config.scrubs[:body]
  end
end
