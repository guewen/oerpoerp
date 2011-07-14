module OerpOerp

  require File.dirname(__FILE__) + '/ooor_common'

  class OoorTarget < ProxyTarget
    include OoorCommon

    register_proxy :ooor
    connect_from :target

    def save(data_record)
      data_record ||= {}

      if data_record.include? :id
        puts "write #{data_record}"
      else
        puts "create #{data_record}"
      end
    end
  end

end