module OerpOerp

  class OoorTarget < ProxyTarget
    include OoorFieldsIntrospection
    include OoorImportReferences

    register_proxy :ooor

  end

end