class LHC::Auth < LHC::Interceptor

  def before_request(request)
    options = request.options[:auth] || {}
    authenticate!(request, options)
  end

  private

  def authenticate!(request, options)
    if options[:bearer]
      bearer_authentication!(request, options)
    elsif options[:basic]
      basic_authentication!(request, options)
    end
  end

  def basic_authentication!(request, options)
    auth = options[:basic]
    credentials = "#{auth[:username]}:#{auth[:password]}"
    set_authorization_header request, "Basic #{Base64.encode64(credentials).chomp}"
  end

  def bearer_authentication!(request, options)
    token = options[:bearer]
    token = token.call if token.is_a?(Proc)
    set_authorization_header request, "Bearer #{token}"
  end

  def set_authorization_header(request, value)
    request.headers['Authorization'] = value
  end
end
