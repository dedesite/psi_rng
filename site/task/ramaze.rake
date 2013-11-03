# This file contains a predefined set of Rake tasks that can be useful when
# developing Ramaze applications. You're free to modify these tasks to your
# liking, they will not be overwritten when updating Ramaze.

namespace :ramaze do
  app = File.expand_path('../../app', __FILE__)

  desc 'Starts a Ramaze console using IRB'
  task :irb do
    require app
    require 'irb'
    require 'irb/completion'

    ARGV.clear
    IRB.start
  end

  # Pry can be installed using `gem install pry`.
  desc 'Starts a Ramaze console using Pry'
  task :pry do
    require app
    require 'pry'

    ARGV.clear
    Pry.start
  end

  # In case you want to use a different server or port you can freely modify
  # the options passed to `Ramaze.start()`.
  desc 'Starts Ramaze for development'
  task :start do
    require app

    Ramaze.start(
      :adapter => :webrick,
      :port    => 7000,
      :file    => __FILE__,
      :root    => Ramaze.options.roots
    )
  end

  desc 'Lists all the routes defined using Ramaze::Route'
  task :routes do
    require app

    if Ramaze::Route::ROUTES.empty?
      abort 'No routes have been defined using Ramaze::Route'
    end

    spacing = Ramaze::Route::ROUTES.map { |k, v| k.to_s }
    spacing = spacing.sort { |l, r| r.length <=> l.length }[0].length

    Ramaze::Route::ROUTES.each do |from, to|
      puts "%-#{spacing}s => %s" % [from, to]
    end
  end
end
