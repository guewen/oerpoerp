module OerpOerp
  class Module

    def attr_writer_as_symbol(*syms)
      syms.each do | sym |
        module_eval do
          define_method("#{sym}=") do |value|
            raise ArgumentError, "Argument of class #{value.class} cannot be converted to a symbol." unless value.respond_to? :to_sym
            instance_variable_set("@#{sym}", value.to_sym)
          end
        end
      end
      nil
    end
  end
end