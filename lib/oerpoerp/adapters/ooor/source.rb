module OerpOerp

  class OoorSource < ProxySource
    include OoorFieldsIntrospection
    include OoorImportReferences

    register_proxy :ooor

  end

end