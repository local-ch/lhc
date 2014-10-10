class LHC::Interceptor

  include Opt

  attr_accessor :priority

  cattr_accessor :interceptors
  @@interceptors = []

  def before_request(request); end
  def after_request(request); end

  def before_response(request); end
  def after_response(response); end

  def self.intercept!(name, target)
    interceptors.each do |interceptor|
      next if opted_out?(interceptor, target)
      interceptor.send(name, target)
    end
  end

  private

  def self.inherited(interceptor)
    @@interceptors.push(interceptor.new)
    LHC::Interceptor.sort!
    super
  end

  # Sort interceptors by priority
  def self.sort!
    @@interceptors = @@interceptors.sort_by { |interceptor| interceptor.priority }
  end
end
