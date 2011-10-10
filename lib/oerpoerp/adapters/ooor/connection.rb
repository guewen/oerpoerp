module OerpOerp

  class OoorProxy < BasicObject
    attr_reader :oerp

    ::OerpOerp::Pooler.register_class_proxy(:ooor, self)

    def initialize(connection_name)
      @adapter_options = ::OerpOerp::OPTIONS[:ooor]
      options = @adapter_options[:connections][connection_name]
      options.merge! :log_level => ::Logger::INFO, :scope_prefix => connection_name.to_s.capitalize
      @oerp = ::Ooor.new(options)
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