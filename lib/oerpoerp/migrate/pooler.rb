module OerpOerp
  class Pooler
    class << self
      def get(method, from)
        Connection.proxy_for(method, from)
      end
    end
  end
end