require 'singleton'

class LHC::Config
  include Singleton

  attr_accessor :config

  def initialize
    self.config = {}
  end

  def self.set(name, options)
    instance.config[name] = options
  end

  def self.[](name)
    instance.config[name]
  end
end
