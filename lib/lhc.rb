module LHC
end

Gem.find_files('lhc/**/*.rb').each { |path| require path }
