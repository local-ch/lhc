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

Gem.find_files('lhc/**/*.rb')
  .sort
  .reject do |path|
    (!defined?(Rails) && File.basename(path).include?('railtie.rb')) || # don't require railtie if Rails is not around
      path.match(%r{\/test\/.*_helper}) # don't require test helper (as we ask people to explicitly require if needed)
  end.each do |path|
    require path
  end
