module OerpOerp

  class OpenERPField

    # TODO ?
    # include Comparable

    attr_accessor :name, :type, :relation, :description

    def initialize(attributes={})
      attributes.each do |key, value|
        method_key = "#{key}=".to_sym
        next unless self.respond_to? method_key
        next unless value
        next if value.empty?
        self.send(method_key, value)
      end
    end

    def ==(other)
      return true if other.equal?(self)

      equality_attributes = [:name, :type, :relation]

      equality_attributes.each do |attr|
        return false unless other.respond_to?(attr)
      end

      equality_attributes.reject { |attr| self.send(attr) == other.send(attr)}.empty?
    end

    def conflict(other_field)
      return false if other_field.equal?(self)
      return false if self == other_field
      return false if self.name != other_field.name
      
      [:type, :relation].each do |attr|
        return true unless other_field.respond_to? attr
        return true if self.send(attr) != other_field.send(attr)
      end
      false
    end

  end

end