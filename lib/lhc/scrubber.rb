# frozen_string_literal: true

class LHC::Scrubber
  attr_accessor :scrubbed

  SCRUB_DISPLAY = '[FILTERED]'

  def initialize(data)
    @scrubbed = data.deep_dup
  end

  private

  def scrub_auth_elements
    LHC.config.scrubs.dig(:auth)
  end

  def scrub!
    return if scrub_elements.blank?
    return if scrubbed.blank?

    LHC::Scrubber.scrub_hash!(scrub_elements, scrubbed) if scrubbed.is_a?(Hash)
    LHC::Scrubber.scrub_array!(scrub_elements, scrubbed) if scrubbed.is_a?(Array)
  end

  def self.scrub_array!(scrub_elements, scrubbed)
    scrubbed.each do |scrubbed_hash|
      LHC::Scrubber.scrub_hash!(scrub_elements, scrubbed_hash)
    end
  end

  def self.scrub_hash!(scrub_elements, scrubbed)
    scrub_elements.each do |scrub_element|
      if scrubbed.key?(scrub_element.to_s)
        key = scrub_element.to_s
      elsif scrubbed.key?(scrub_element.to_sym)
        key = scrub_element.to_sym
      end
      next if key.blank?
      next if scrubbed[key].blank?

      scrubbed[key] = SCRUB_DISPLAY
    end
    scrubbed.values.each { |v| LHC::Scrubber.scrub_hash!(scrub_elements, v) if v.instance_of?(Hash) }
  end
end
