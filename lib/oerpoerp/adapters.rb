require 'oerpoerp/adapters/adapters'

%w{ ooor sequel static }.each do |adapter|
  Dir["#{File.dirname(__FILE__)}/adapters/#{adapter}/*.rb"].sort.each do |path|
    require "oerpoerp/adapters/#{adapter}/#{File.basename(path, '.rb')}"
  end
end