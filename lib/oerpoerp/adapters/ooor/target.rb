module OerpOerp

  class OoorTarget < ProxyTarget
    include OoorFieldsIntrospection
    include OoorImportReferences

    register_proxy :ooor


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