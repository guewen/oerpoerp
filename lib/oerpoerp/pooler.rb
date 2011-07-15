module OerpOerp
  class Pooler

    class << self

      def proxy_for(method, *args)
        proxy_class = self.class_proxy_for(method)
        return proxy_class.new(*args) if proxy_class
        nil
      end

      def register_class_proxy(method, klass)
        @proxy ||= {}
        @proxy[method] = klass
      end

      def class_proxy_for(method)
        @proxy[method] if @proxy
      end

      def get(method, from)
        @connection_instances ||= {}
        return @connection_instances[from] if @connection_instances[from]
        @connection_instances[from] = self.proxy_for(method, from)
        @connection_instances[from]
      end
    end
  end
end