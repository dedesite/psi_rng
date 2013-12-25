#
# Environment settings
#

#Don't understand why NoCache isn't working...
#require "rack/nocache"
require "rack/coffee"

Ramaze.middleware :spec do |mode|
  puts "Middlewares for spec"
  mode.use Rack::Lint
  mode.use Rack::CommonLogger, Ramaze::Log
  mode.use Rack::ShowExceptions
  mode.use Rack::ShowStatus
  mode.use Rack::RouteExceptions
  mode.use Rack::ConditionalGet
  mode.use Rack::ETag
  mode.use Rack::Head
  mode.use Rack::Coffee,
    :root => "#{Dir.pwd}/public",
    :urls => '/js'
end

Ramaze.middleware :dev do |mode|
  puts "Middlewares for dev"
  mode.use Rack::Lint
  mode.use Rack::CommonLogger, Ramaze::Log
  mode.use Rack::ShowExceptions
  mode.use Rack::ShowStatus
  mode.use Rack::RouteExceptions
  mode.use Rack::ConditionalGet
  mode.use Rack::ETag
  mode.use Rack::Head
  #mode.use Rack::NoCache
  mode.use Rack::Coffee,
    :root => "#{Dir.pwd}/public",
    :urls => '/js'
  mode.use Ramaze::Reloader
  mode.run Ramaze::AppMap
end

Ramaze.middleware :live do |mode|
  puts "Middlewares for live"
  mode.use Rack::CommonLogger, Ramaze::Log
  mode.use Rack::ShowExceptions
  mode.use Rack::ShowStatus
  mode.use Rack::RouteExceptions
  mode.use Rack::ConditionalGet
  mode.use Rack::ETag
  mode.use Rack::Head
end

# Default is 'spec'
if ENV['RACK_ENV'].nil?
  Ramaze::Log.info('Environment not set; using %s mode' % Ramaze.options.mode.to_s)
elsif !["spec", "live", "dev"].include?(ENV["RACK_ENV"])
  Ramaze::Log.info("Warning : environment '%s' unknown, using %s mode" % [ ENV['RACK_ENV'], Ramaze.options.mode.to_s ])
else
  Ramaze.options.mode = ENV["RACK_ENV"].to_sym
end

Ramaze::Log.info('We start in %s mode' % Ramaze.options.mode.to_s)