oerpoerp_path = File.expand_path('../../../oerpoerp/lib', __FILE__)
$:.unshift(oerpoerp_path) if File.directory?(oerpoerp_path) && !$:.include?(oerpoerp_path)

require 'rubygems'
require 'pp'
require 'colorize'
require 'hirb'
require 'hashery/orderedhash'
require 'ooor'

require 'oerpoerp/core_ext'
require 'oerpoerp/version'
require 'oerpoerp/migration_dsl'
require 'oerpoerp/core'
require 'oerpoerp/actions'
require 'oerpoerp/model_matcher'
require 'oerpoerp/pooler'
require 'oerpoerp/openerp_field'
require 'oerpoerp/openerp_model'
require 'oerpoerp/adapters'

module OerpOerp

  # TODO implement options in a global migration file
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


  r = MigrationCore.new
  r.initialize_from_file( ARGV[0] )
  r.run

end