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

      def get(method, connection_name)
        @connection_instances ||= {}
        return @connection_instances[connection_name] if @connection_instances[connection_name]
        @connection_instances[connection_name] = self.proxy_for(method, connection_name)
        @connection_instances[connection_name]
      end
    end
  end
end