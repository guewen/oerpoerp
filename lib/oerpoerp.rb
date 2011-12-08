oerpoerp_path = File.expand_path('../../../oerpoerp/lib', __FILE__)
$:.unshift(oerpoerp_path) if File.directory?(oerpoerp_path) && !$:.include?(oerpoerp_path)

require 'rubygems'
require 'pp'
require 'colorize'
require 'hirb'
require 'hashery/orderedhash'
require 'ooor'
require 'ruby-debug'

require 'oerpoerp/core_ext'
require 'oerpoerp/version'
require 'oerpoerp/ooor_ext'
require 'oerpoerp/core'
require 'oerpoerp/actions'
require 'oerpoerp/target_line'
require 'oerpoerp/model_matcher'
require 'oerpoerp/pooler'
require 'oerpoerp/openerp_field'
require 'oerpoerp/openerp_model'
require 'oerpoerp/adapters'

module OerpOerp

  # TODO implement options in a global migration file using DSL syntax or YAML ?
OPTIONS = {
  :name => 'a_static_migration',
  :verbose => true,
  :simulation => false,

  :ooor => {
      :default_source_connection => :conn1,
      :default_target_connection => :conn2,
      :connections => {
        :conn1 => {
          :url => 'http://localhost:8069/xmlrpc',
          :database => 'oerp_source',
          :username => 'admin',
          :password => 'admin'
        },
        :conn2 => {
          :url => 'http://localhost:8079/xmlrpc',
          :database => 'oerp_target',
          :username => 'admin',
          :password => 'admin'
        }
      }
    }
  }


  Migration.add(ARGV[0])
  Migration.sort!
  Migration.migrations.each do |migration|
    migration.run
  end

end