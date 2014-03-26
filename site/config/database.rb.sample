require 'logger'

DB = Sequel.mysql2(
  'psi_rng',
  :user=>'root',
  :password=>'root',
  :charset=>'utf8')

Sequel.extension(:pagination)
Sequel.extension(:migration)

#Uncomment this if you want to log all DB queries
#DB.loggers << Logger.new($stdout)
