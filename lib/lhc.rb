Dir[File.dirname(__FILE__) + '/lhc/concerns/lhc/*.rb'].each {|file| require file }

module LHC
  include Get
end

Gem.find_files('lhc/**/*.rb').each { |path| require path }
