module OerpOerp

  class OoorProxy < BasicObject
    attr_reader :oerp

    Pooler.register_class_proxy(:ooor, OoorProxy)

    def initialize(from)
      @adapter_options = OerpOerp::OPTIONS[:ooor]
      options = @adapter_options[from]
      options.merge! :log_level => Logger::INFO, :scope_prefix => from.to_s.capitalize
      @oerp = Ooor.new(options)
    end

    def [](model)
      @oerp.const_get(model)
    end

    protected

    def method_missing(name, *args, &block)
      @oerp.send(name, *args, &block)
    end

  end

end