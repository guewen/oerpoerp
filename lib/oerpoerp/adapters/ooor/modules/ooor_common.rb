module OerpOerp

  module OoorCommon

    def connect
      # fixme move the connection before the migration
      @oerp = Ooor.new(adapter_options[:source].merge(:log_level => Logger::INFO)) #.merge(:scope_prefix => :Source)
    end

    def model
      #@model = const_get(@model_name)
    end

    def disconnect
      # nothing to do at model level
    end

  end

end