module OerpOerp

  require File.dirname(__FILE__) + '/static_common'

  class StaticTarget < TargetBase
    include OerpOerp::StaticCommon

    register_proxy :static
    connect_from :target

  end

end