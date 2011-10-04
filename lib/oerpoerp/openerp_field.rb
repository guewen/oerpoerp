module OerpOerp

  class OpenERPField

    attr_writer_as_symbol :name, :ttype, :relation
    attr_reader :name, :ttype, :relation, :model

    def initialize(attributes={})
      attributes.each do |key, value|
        method_key = "#{key}=".to_sym
        next unless self.respond_to? method_key
        self.send(method_key, value)
      end
    end

    def ==(other)
      return true if other.equal?(self)

      equality_attributes = [:name, :ttype, :relation]

      equality_attributes.each do |attr|
        return false unless other.respond_to?(attr)
      end

      equality_attributes.reject { |attr| self.send(attr) == other.send(attr)}.empty?
    end

  end

end