module OerpOerp
  module AdaptersFactory

    module ClassMethods
      attr_reader :proxy_classes

      def proxy_for(method)
        proxy_class = self.proxy_classes.find do |klass|
          klass.proxy_for?(method)
        end
        return proxy_class.new if proxy_class
        nil
      end

      def register_proxy(proxy)
        @proxy_for = proxy
      end

      def proxy_for?(proxy)
        @proxy_for == proxy
      end

      def inherited(subclass)
        self.proxy_classes << subclass
      end
    end

    def self.included(host_class)
      host_class.extend(ClassMethods)
    end

  end


  class ProxySource
    include AdaptersFactory
    @proxy_classes = []
  end

  class ProxyTarget
    include AdaptersFactory
    @proxy_classes = []


    def save(data_record)

    end

  end


  class ProxyFieldsIntrospection
    include AdaptersFactory
    @proxy_classes = []

  end


end