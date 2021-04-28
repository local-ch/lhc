# frozen_string_literal: true

class LHC::ParamsScrubber < LHC::Scrubber
  def initialize(data)
    super(data)
    scrub!
  end

  private

  def scrub_elements
    LHC.config.scrubs[:params]
  end
end
