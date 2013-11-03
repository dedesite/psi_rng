require File.expand_path('../../app', __FILE__)

# This file can be used to set various configuration options for your testing
# suite. Ramaze itself uses Bacon but you're not forced to use this. Want to
# use Rspec instead? Go ahead!
#
# If you do happen to use Bacon you can uncomment the following lines to get
# started with testing Ramaze using Bacon:
#
# require 'bacon'
# require 'ramaze/spec/bacon'

# The following code is an example on how to set up Capybara
# (https://github.com/jnicklas/capybara) for Ramaze. If you don't use Capybara
# you can safely remove these comments.
#
# require 'capybara/dsl'
#
# Capybara.configure do |config|
#   config.default_driver = :rack_test
#   config.app            = Ramaze
# end
#
# shared :capybara do
#   Ramaze.setup_dependencies
#
#   extend Capybara::DSL
# end
#

# The following few lines of code are the most basic settings you'll want to
# use for testing Ramaze. They ensure that the environment is set correctly and
# that your output isn't clogged with non important information.
Ramaze.middleware :spec do
  run Ramaze.core
end

Ramaze::Log.level   = Logger::ERROR
Ramaze.options.mode = :spec
