module OerpOerp

  require File.dirname(__FILE__) + '/static_common'

  class StaticSource < SourceBase
    include OerpOerp::StaticCommon

    register_proxy :static

  end


end