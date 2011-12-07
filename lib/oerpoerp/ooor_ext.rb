Dir["#{File.dirname(__FILE__)}/ooor_ext/*.rb"].sort.each do |path|
  require "oerpoerp/ooor_ext/#{File.basename(path, '.rb')}"
end