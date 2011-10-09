module OerpOerp

  require File.dirname(__FILE__) + '/ooor_common'

  class OoorSource < SourceBase
    include OoorCommon

    register_proxy :ooor

  end


end