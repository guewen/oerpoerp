module OerpOerp
  module AdaptersFactory

    module ClassMethods
      attr_reader :proxy_classes, :proxy, :connection_from

      def proxy_for(method)
        proxy_class = self.proxy_classes.find do |klass|
          klass.proxy_for?(method)
        end
        return proxy_class.new if proxy_class
        nil
      end

      def connect_from(from)
        @connection_from = from
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


  class ProxySource
    include AdaptersFactory
    @proxy_classes = []

    attr_accessor :model_name
    attr_reader :model

  end

  class ProxyTarget
    include AdaptersFactory
    @proxy_classes = []

    attr_accessor :model_name
    attr_reader :model

    def save(data_record)

    end

  end


end