# frozen_string_literal: true

class LHC::Auth < LHC::Interceptor
  include ActiveSupport::Configurable
  config_accessor :refresh_client_token

  def before_raw_request
    body_authentication! if auth_options[:body]
  end

  def before_request
    bearer_authentication! if auth_options[:bearer]
    basic_authentication! if auth_options[:basic]
  end

  def after_response
    return unless configuration_correct?
    return unless reauthenticate?

    reauthenticate!
  end

  private

  def body_authentication!
    auth = auth_options[:body]
    request.options[:body] = (request.options[:body] || {}).merge(auth)
  end

  def basic_authentication!
    auth = auth_options[:basic]
    credentials = "#{auth[:username]}:#{auth[:password]}"
    set_basic_authorization_header(Base64.strict_encode64(credentials).chomp)
  end

  def bearer_authentication!
    token = auth_options[:bearer]
    token = token.call if token.is_a?(Proc)
    set_bearer_authorization_header(token)
  end

  # rubocop:disable Naming/AccessorMethodName
  def set_authorization_header(value)
    request.headers['Authorization'] = value
  end

  def set_basic_authorization_header(base_64_encoded_credentials)
    request.options[:auth][:basic].merge!(base_64_encoded_credentials: base_64_encoded_credentials)
    set_authorization_header("Basic #{base_64_encoded_credentials}")
  end

  def set_bearer_authorization_header(token)
    auth_options = request.options[:auth] || {}
    auth_options.merge!(bearer_token: token)
    request.options[:auth] = auth_options unless request.options.key?(:auth)

    set_authorization_header("Bearer #{token}")
  end
  # rubocop:enable Naming/AccessorMethodName

  def reauthenticate!
    # refresh token and update header
    token = refresh_client_token_option.call
    set_bearer_authorization_header(token)
    # trigger LHC::Retry and ensure we do not trigger reauthenticate!
    # again should it fail another time
    new_options = request.options.dup
    new_options = new_options.merge(retry: { max: 1 })
    new_options = new_options.merge(auth: { reauthenticated: true })
    request.options = new_options
  end

  def reauthenticate?
    !response.success? &&
      !auth_options[:reauthenticated] &&
      bearer_header_present? &&
      LHC::Error.find(response) == LHC::Unauthorized
  end

  def bearer_header_present?
    @has_bearer_header ||= request.headers['Authorization'] =~ /^Bearer .+$/i
  end

  def refresh_client_token_option
    @refresh_client_token_option ||= auth_options[:refresh_client_token] || refresh_client_token
  end

  def auth_options
    request.options[:auth] || {}
  end

  def configuration_correct?
    # warn user about configs, only if refresh_client_token_option is set at all
    refresh_client_token_option && refresh_client_token? && retry_interceptor?
  end

  def refresh_client_token?
    return true if refresh_client_token_option.is_a?(Proc)

    warn("[WARNING] The given refresh_client_token must be a Proc for reauthentication.")
  end

  def retry_interceptor?
    return true if all_interceptor_classes.include?(LHC::Retry) && all_interceptor_classes.index(LHC::Retry) > all_interceptor_classes.index(self.class)

    warn("[WARNING] Your interceptors must include LHC::Retry after LHC::Auth.")
  end
end
