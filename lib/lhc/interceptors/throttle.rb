# frozen_string_literal: true

require 'active_support/duration'

class LHC::Throttle < LHC::Interceptor

  class OutOfQuota < StandardError
  end

  class << self
    attr_accessor :track
  end

  def before_request
    options = request.options.dig(:throttle)
    return unless options
    break_options = options.dig(:break)
    return unless break_options
    break_when_quota_reached! if break_options.match('%')
  end

  def after_response
    options = response.request.options.dig(:throttle)
    return if throttling_futile?(options)
    self.class.track ||= {}
    self.class.track[options.dig(:provider)] = {
      limit: limit(options: options[:limit], response: response),
      remaining: remaining(options: options[:remaining], response: response),
      expires: expires(options: options[:expires], response: response)
    }
  end

  private

  def throttling_futile?(options)
    [options&.dig(:track), response.headers].any?(&:blank?)
  end

  def break_when_quota_reached!
    options = request.options.dig(:throttle)
    track = (self.class.track || {}).dig(options[:provider])
    return if track.blank? || track[:remaining].blank? || track[:limit].blank? || track[:expires].blank?
    return if Time.zone.now > track[:expires]
    # avoid floats by multiplying with 100
    remaining = track[:remaining] * 100
    limit = track[:limit]
    quota = 100 - options[:break].to_i
    raise(OutOfQuota, "Reached predefined quota for #{options[:provider]}") if remaining < quota * limit
  end

  def limit(options:, response:)
    @limit ||=
      begin
        if options.is_a?(Integer)
          options
        elsif options.is_a?(Hash) && options[:header] && response.headers.present?
          response.headers[options[:header]]&.to_i
        end
      end
  end

  def remaining(options:, response:)
    @remaining ||=
      begin
        if options.is_a?(Proc)
          options.call(response)
        elsif options.is_a?(Hash) && options[:header] && response.headers.present?
          response.headers[options[:header]]&.to_i
        end
      end
  end

  def expires(options:, response:)
    @expires ||= convert_expires(read_expire_option(options, response))
  end

  def read_expire_option(options, response)
    if options.is_a?(Hash) && options[:header] && response.headers.present?
      response.headers[options[:header]]
    else
      options
    end
  end

  def convert_expires(value)
    return Time.parse(value) if value.match(/GMT/)
    Time.zone.at(value.to_i).to_datetime if value.present?
  end
end
