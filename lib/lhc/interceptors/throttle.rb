# frozen_string_literal: true

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
    return unless options
    return unless options.dig(:track)
    self.class.track ||= {}
    self.class.track[options.dig(:provider)] = {
      limit: limit(options: options[:limit], response: response),
      remaining: remaining(options: options[:remaining], response: response)
    }
  end

  private

  def break_when_quota_reached!
    options = request.options.dig(:throttle)
    track = (self.class.track || {}).dig(options[:provider])
    return unless track
    # avoid floats by multiplying with 100
    remaining = track[:remaining] * 100
    limit = track[:limit]
    quota = 100 - options[:break].to_i
    raise(OutOfQuota, "Reached predefined quota for #{options[:provider]}") if remaining < quota * limit
  end

  def limit(options:, response:)
    @limit ||= begin
      if options.is_a?(Integer)
        options
      elsif options.is_a?(Hash) && options[:header]
        response.headers[options[:header]]&.to_i
      end
    end
  end

  def remaining(options:, response:)
    @remaining ||= begin
      if options.is_a?(Hash) && options[:header]
        response.headers[options[:header]]&.to_i
      end
    end
  end
end
