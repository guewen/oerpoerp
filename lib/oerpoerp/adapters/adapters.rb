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

  class SourceBase
    include AdaptersFactory
    include ConnectionFrom
    @proxy_classes = []

    attr_accessor :model_name
    attr_reader :model

  end

  class TargetBase
    include AdaptersFactory
    include ConnectionFrom
    @proxy_classes = []

    attr_accessor :model_name
    attr_reader :model

    def save(data_record)

    end

  end
end