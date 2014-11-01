require 'singleton'

class LHC::Config
  include Singleton

  attr_accessor :config, :default_interceptors

  def initialize
    self.config = {}
  end

  def self.set(name, endpoint, options = {})
    fail 'Configuration already exists for that name' if instance.config[name]
    instance.config[name] = OpenStruct.new({
      endpoint: endpoint,
      options: options
    })
  end

  def self.[](name)
    config = instance.config[name]
    return config.dup if config
  end
end
