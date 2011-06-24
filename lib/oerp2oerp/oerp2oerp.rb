require 'migrate/base'
require 'pp'

r = MigrateBase.new
r.initialize_from_file( ARGV[0] )

pp r
r.run
