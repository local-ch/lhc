require 'singleton'

class LHC::Config
  include Singleton

  attr_accessor :config

  def initialize
    self.config = {}
  end

  def self.set(name, endpoint, params = {})
    instance.config[name] = OpenStruct.new({
      endpoint: endpoint,
      params: params
    })
  end

  def self.[](name)
    instance.config[name]
  end
end
