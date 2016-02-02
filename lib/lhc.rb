Dir[File.dirname(__FILE__) + '/lhc/concerns/lhc/*.rb'].sort.each { |file| require file }

module LHC
  include BasicMethods
  include Formats

  def self.config
    LHC::Config.instance
  end

  def self.configure
    LHC::Config.instance.reset
    yield config
  end
end

Gem.find_files('lhc/**/*.rb').sort.each { |path| require path }
