Dir[File.dirname(__FILE__) + '/lhc/concerns/lhc/*.rb'].each {|file| require file }

module LHC
  include BasicMethods

  def self.config
    LHC::Config.instance
  end
end


Gem.find_files('lhc/**/*.rb').each { |path| require path }
