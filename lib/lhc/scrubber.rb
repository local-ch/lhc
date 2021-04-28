# frozen_string_literal: true

class LHC::Scrubber
  attr_reader :scrubbed

  SCRUB_DISPLAY = '[FILTERED]'

  def initialize(data)
    @data = data
    @scrubbed = data.deep_dup
  end

  private

  attr_reader :data, :scrub_elements, :scrub_auth_elements

  def scrub_auth_elements
    LHC.config.scrubs.dig(:auth)
  end

  def scrub!
    return if scrub_elements.blank?
    return if scrubbed.blank?

    scrub_elements.each do |scrub_element|
      if scrubbed.has_key?(scrub_element.to_s)
        key = scrub_element.to_s
      elsif scrubbed.has_key?(scrub_element.to_sym)
        key = scrub_element.to_sym
      end
      next if key.blank?
      scrubbed[key] = SCRUB_DISPLAY
    end
  end
end
