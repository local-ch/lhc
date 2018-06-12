class LHC::Auth < LHC::Interceptor
  include ActiveSupport::Configurable
  config_accessor :refresh_client_token, :max_recovery_attempts

  def before_request
    authenticate!
  end

  def after_response
    return unless configuration_correct?
    return unless attempt_recovery?
    attempt_recovery
  end

  private

  def authenticate!
    if auth_options[:bearer]
      bearer_authentication!
    elsif auth_options[:basic]
      basic_authentication!
    end
  end

  def basic_authentication!
    auth = auth_options[:basic]
    credentials = "#{auth[:username]}:#{auth[:password]}"
    set_authorization_header("Basic #{Base64.encode64(credentials).chomp}")
  end

  def bearer_authentication!
    token = auth_options[:bearer]
    token = token.call if token.is_a?(Proc)
    set_bearer_authorization_header(token)
  end

  # rubocop:disable Style/AccessorMethodName
  def set_authorization_header(value)
    request.headers['Authorization'] = value
  end

  def set_bearer_authorization_header(token)
    set_authorization_header("Bearer #{token}")
  end
  # rubocop:enable Style/AccessorMethodName

  def attempt_recovery
    # refresh token and update header
    token = refresh_client_token_option.call
    set_bearer_authorization_header(token)
    # write state into request options hash - trigger LHC::Retry once - count recovery_attempts
    request_options = request.options.dup
    request_options[:auth] ||= {}
    request_options[:retry] = { max: 1 }
    request.options = request_options
    request_options[:auth][:recovery_attempts] ||= 0
    request_options[:auth][:recovery_attempts] += 1
    request.options = request_options
  end

  def attempt_recovery?
    !response.success? &&
      !(auth_options[:recovery_attempts] || 0 < max_recovery_attempts_option) &&
      bearer_header_present? &&
      LHC::Error.find(response) == LHC::Unauthorized
  end

  def bearer_header_present?
    @has_bearer_header ||= request.headers['Authorization'] =~ /^Bearer [0-9a-f-]+$/i
  end

  def refresh_client_token_option
    @refresh_client_token_option ||= auth_options[:refresh_client_token] || refresh_client_token
  end

  def max_recovery_attempts_option
    @max_recovery_attempts ||= auth_options[:max_recovery_attempts] || max_recovery_attempts || 0
  end

  def all_interceptor_classes
    @all_interceptors ||= LHC::Interceptors.new(request).all.map(&:class)
  end

  def auth_options
    @auth_options ||= request.options[:auth].dup || {}
  end

  def configuration_correct?
    # only check the configuration if we got the request to attempt a recovery
    issues = []
    if max_recovery_attempts_option >= 1
      unless refresh_client_token_option.is_a?(Proc)
        issues << "the given refresh_client_token is either not set or not a Proc"
      end
      unless all_interceptor_classes.include?(LHC::Retry) && all_interceptor_classes.index(LHC::Retry) > all_interceptor_classes.index(self.class)
        issues << "your interceptor chain needs to include LHC::Retry after LHC::Auth"
      end
      warn("[WARNING] Check the configuration for LHC::Auth interceptor, it's misconfigured for a retry attempt: #{issues.join('|')}") unless issues.empty?
    end
    issues.empty?
  end
end
