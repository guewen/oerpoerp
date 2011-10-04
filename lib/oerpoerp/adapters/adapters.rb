module OerpOerp
  module AdaptersFactory

    module ClassMethods
      attr_reader :proxy_classes, :proxy

      def proxy_for(method, *args)
        proxy_class = self.proxy_classes.find do |klass|
          klass.proxy_for?(method)
        end
        return proxy_class.new(*args) if proxy_class
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
      @adapter_options ||= OPTIONS[self.class.proxy]
    end

  end

  module ConnectionFrom

    module ClassMethods
      attr_reader :connection_from

      def connect_from(from)
        @connection_from = from
      end

      def connect_from?(from)
        @connection_from == from
      end

      def inherited(subclass)
        self.proxy_classes << subclass
      end
    end

    def self.included(host_class)
      host_class.extend(ClassMethods)
    end

  end

  module SourceTargetCommon
    
    attr_accessor :name
    attr_accessor :model_name
    attr_reader :model

    def model_definition
      return @model_definition if defined? @model_definition
      @model_definition = OerpOerp::OpenERPModel.new(@model_name)
      get_fields.each do |field|
        @model_definition << field
      end
      @model_definition
    end

    def initialize(&block)
      yield self if block_given?
    end

    def model(name)
      @name = name
    end

  end

  class SourceBase
    include AdaptersFactory
    include ConnectionFrom
    include SourceTargetCommon
    @proxy_classes = []

    attr_reader :data_iterator

    def default_iterator
      # must be a proc containing a object responding to #each
      Proc.new { [] }
    end

    def lines
      block = @data_iterator || default_iterator
      block.call
    end

    # DSL Methods

    def iterate_on(&block)
      @data_iterator = block
    end

  end

  class TargetBase
    include AdaptersFactory
    include ConnectionFrom
    include SourceTargetCommon
    @proxy_classes = []

    def insert(data_record)

    end

    def update(id, data_record)
      
    end

  end
end