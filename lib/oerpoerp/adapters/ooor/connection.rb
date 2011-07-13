module OerpOerp

  class OoorConnection < Connection
    register_proxy :ooor

    def initialize(from)
      options = adapter_options[from]
      options.merge! :log_level => Logger::INFO, :scope_prefix => from.to_s.capitalize
      @oerp = Ooor.new(options)
    end

  end


end