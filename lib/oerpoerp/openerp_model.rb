module OerpOerp

  class OpenERPModel

    attr_accessor :name
    attr_reader :fields

    def initialize(name)
      @name = name
      @fields = {}
    end

    def add_field(attributes={})
      raise "A field must have a name!" unless attributes.include? :name
      raise "Field name must be unique (#{attributes[:name]})!" if @fields.include? attributes[:name]
      @fields[attributes[:name]] = OerpOerp::OpenERPField.new(attributes)
    end

    alias_method :<<, :add_field

    def [](name)
      @fields[name]
    end

    def table_name
      @name.gsub!('.', '_')
    end

  end

end