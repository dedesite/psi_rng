# Require settings
Ramaze::Log.debug("Requiring configs")

Dir.glob(Ramaze.options.roots.first + '/config/*.rb').each do |file|
 file = file.match(/config\/(.*)\.rb/)[1]
  next if file == "init"
  Ramaze::Log.debug("Loading config #{file}")
  require __DIR__(file)
end