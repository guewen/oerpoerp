module OerpOerp

  class OpenERPField

    attr_writer :name, :ttype, :relation
    attr_reader :name, :ttype, :relation

    def initialize(name, ttype, relation)
      self.name = name
      self.ttype = ttype
      self.relation = relation
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