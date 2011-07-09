module OerpOerp

  require File.dirname(__FILE__) + '/modules/ooor_common'

  class OoorSource < ProxySource
    include OoorCommon
    include OoorFieldsIntrospection
    include OoorImportReferences

    register_proxy :ooor

  end


end