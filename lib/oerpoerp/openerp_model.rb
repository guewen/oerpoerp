module OerpOerp

  class OpenERPModel

    attr_accessor :name
    attr_reader :fields

    def initialize(name)
      @name = name
      @fields = []
    end

    def add_field(attributes={})
      raise "A field must have a name!" unless attributes.include? :name
      raise "Field name must be unique (#{attributes[:name]})!" if @fields.include? attributes[:name]
      @fields << OerpOerp::OpenERPField.new(attributes)
    end

    alias_method :<<, :add_field

    def [](name)
      @fields[name]
    end

    def table_name
      @name.gsub!('.', '_')
    end

    def matching_fields(other_model)
      raise Exception("#{other_model} cannot be compared with model.") unless other_model.respond_to? :fields
      @fields.select { |field| other_model.fields.include? field }
    end

    def conflicting_fields(other_model)
      raise Exception("#{other_model} cannot be compared with model.") unless other_model.respond_to? :fields
      non_matching_fields = @fields - matching_fields(other_model)
      non_matching_fields.select do |field|
        !other_model.fields.select {|rfield| field.conflict(rfield)}.empty?
      end
    end

    def one_side_fields(other_model)
      raise Exception("#{other_model} cannot be compared with model.") unless other_model.respond_to? :fields
      non_matching_fields = matching_fields(other_model)
      conflict_fields = conflicting_fields(other_model)
      @fields - non_matching_fields - conflict_fields
    end

  end

end