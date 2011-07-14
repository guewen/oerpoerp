module OerpOerp

  require File.dirname(__FILE__) + '/ooor_common'

  class OoorSource < ProxySource
    include OoorCommon

    register_proxy :ooor
    connect_from :source

  end


end