require 'pp'

require 'rubygems'
require 'hashery/orderedhash'

require File.dirname(__FILE__) + '/migrate/base'

module OerpOerp

  VERSION = "0.1.0"

  r = MigrateBase.new
  r.initialize_from_file( ARGV[0] )

  pp r
  r.run

end