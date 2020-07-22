# frozen_string_literal: true

class LHC::Auth < LHC::Interceptor
  include ActiveSupport::Configurable
  config_accessor :refresh_client_token

  def before_request
    authenticate!
  end

  def after_response
    return unless configuration_correct?
    return unless reauthenticate?
    reauthenticate!
  end

  private

  def authenticate!
    if auth_options[:bearer]
      bearer_authentication!
    elsif auth_options[:basic]
      basic_authentication!
    elsif auth_options[:api_key]
      api_key_authentication!
    end
  end

  def basic_authentication!
    auth = auth_options[:basic]
    credentials = "#{auth[:username]}:#{auth[:password]}"
    set_authorization_header(key: 'Authorization', value: "Basic #{Base64.strict_encode64(credentials).chomp}")
  end

  def bearer_authentication!
    token = auth_options[:bearer]
    token = token.call if token.is_a?(Proc)
    set_bearer_authorization_header(token)
  end

  def api_key_authentication!
    key = auth_options[:api_key][:key]
    value = auth_options[:api_key][:value]
    add_to = auth_options[:api_key][:add_to]
    if add_to == :header
      set_authorization_header(key: key, value: value)
    elsif add_to == :body
      set_authorization_body(key: key, value: value)
    end
  end

  # rubocop:disable Style/AccessorMethodName
  def set_authorization_header(key:, value:)
    request.headers[key] = value
  end

  def set_bearer_authorization_header(token)
    set_authorization_header(key: 'Authorization', value: "Bearer #{token}")
  end

  def set_authorization_body(key:, value:)
    auth_body = { key => value }
    provided_body = JSON.parse(request.raw.options[:body])
    body = provided_body.merge(auth_body)
    request.raw.options[:body] = body.to_json
  end
  # rubocop:enable Style/AccessorMethodName

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

  def all_interceptor_classes
    @all_interceptors ||= LHC::Interceptors.new(request).all.map(&:class)
  end

  def auth_options
    @auth_options ||= request.options[:auth].dup || {}
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
