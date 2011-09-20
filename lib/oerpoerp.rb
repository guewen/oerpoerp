require 'rubygems'
require 'pp'
require 'colorize'
require 'hirb'
require 'hashery/orderedhash'
require 'ooor'

require 'oerpoerp/core_ext'
require 'oerpoerp/version'
require 'oerpoerp/core'
require 'oerpoerp/fields_analyzer'
require 'oerpoerp/pooler'
require 'oerpoerp/openerp_field'
require 'oerpoerp/openerp_model'
require 'oerpoerp/adapters'

module OerpOerp

  # TODO implement options
OPTIONS = {
  :verbose => true,
  :simulation => true,
  :ooor => {
      :source => {
        :url => 'http://localhost:8069/xmlrpc',
        :database => 'oerp_source',
        :username => 'admin',
        :password => 'admin'
      },
      :target => {
        :url => 'http://localhost:8079/xmlrpc',
        :database => 'oerp_target',
        :username => 'admin',
        :password => 'admin'
      }
    }
  }

  VERSION = "0.1.0"

  r = MigrateBase.new
  r.initialize_from_file( ARGV[0] )
  r.run

end