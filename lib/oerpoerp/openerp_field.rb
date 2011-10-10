module OerpOerp

  class OpenERPField

    # TODO ?
    # include Comparable

    attr_writer_as_symbol :name, :ttype, :relation
    attr_accessor :description
    attr_reader :name, :ttype, :relation, :model

    def initialize(attributes={})
      attributes.each do |key, value|
        method_key = "#{key}=".to_sym
        next unless self.respond_to? method_key
        next if value.empty?
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

    def conflict(other_field)
      return false if other_field.equal?(self)
      return false if self == other_field
      return false if self.name != other_field.name
      
      [:ttype, :relation].each do |attr|
        return true unless other_field.respond_to? attr
        return true if self.send(attr) != other_field.send(attr)
      end
      false
    end

  end

end