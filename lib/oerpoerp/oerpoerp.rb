require 'rubygems'
require 'pp'
require 'colorize'
require 'hirb'
require 'hashery/orderedhash'
require 'ooor'

require File.dirname(__FILE__) + '/migrate/base'
require File.dirname(__FILE__) + '/migrate/fields_analyzer'
require File.dirname(__FILE__) + '/adapters/adapters'

# load all adapters
MODELS_PATH = File.dirname(__FILE__) + '/adapters/'
Dir[File.join(MODELS_PATH, '**/*.rb')].each do |file|
  require File.join(File.dirname(file), File.basename(file, File.extname(file)))
end


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

module OerpOerp

  VERSION = "0.1.0"


  r = MigrateBase.new
  r.initialize_from_file( ARGV[0] )
  r.run

end