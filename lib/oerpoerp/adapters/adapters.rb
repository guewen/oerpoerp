module OerpOerp
  module AdaptersFactory

    module ClassMethods
      attr_reader :proxy_classes, :proxy

      def proxy_for(method, *args, &block)
        proxy_class = self.proxy_classes.find do |klass|
          klass.proxy_for?(method)
        end
        return proxy_class.new(*args, &block) if proxy_class
        nil
      end

      def register_proxy(proxy)
        @proxy = proxy
      end

      def proxy_for?(proxy)
        @proxy == proxy
      end

      def inherited(subclass)
        self.proxy_classes << subclass
      end
    end

    def self.included(host_class)
      host_class.extend(ClassMethods)
    end

    def adapter_options
      @adapter_options ||= OerpOerp::OPTIONS[self.class.proxy]
    end

  end

  module SourceTargetCommon
    
    attr_accessor :model_name
    attr_reader :model, :connection_name

    def model_structure
      return @model_structure if defined? @model_structure
      @model_structure = OerpOerp::OpenERPModel.new(@model_name)
      get_fields.each do |field|
        @model_structure << field
      end
      @model_structure
    end

    def initialize(*args, &block)
      # todo improve
      @connection_name = args.last[:connection]
      instance_eval(&block) if block
    end

    def base_model(name)
      @model_name = name
    end

  end

  class SourceBase
    include AdaptersFactory
    include SourceTargetCommon
    @proxy_classes = []

    attr_reader :data_iterator

    def connection_name
      @connection_name ||= OerpOerp::OPTIONS[self.class.proxy][:default_source_connection]
      @connection_name
    end

    def default_iterator
      # must be a proc containing a object responding to #each
      Proc.new { [] }
    end

    def lines
      block = @data_iterator || default_iterator
      block.call
    end

    # DSL Methods

    def data(&block)
      @data_iterator = block
    end

  end

  class TargetBase
    include AdaptersFactory
    include SourceTargetCommon
    @proxy_classes = []

    def connection_name
      @connection_name ||= OerpOerp::OPTIONS[self.class.proxy][:default_target_connection]
      @connection_name
    end

    def insert(data_record)

    end

    def update(id, data_record)
      
    end

  end
end