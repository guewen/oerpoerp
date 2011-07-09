module OerpOerp

  module OoorFieldsIntrospection
    def fields
      return @fields if defined? @fields
      @fields = {}
      IrModelFields.find(:all, :domain => [['model', '=', @model_name]],
                         :fields => ['ttype', 'relation', 'name']).each do |field|
        specs = {}
        specs[:ttype] = field.ttype
        specs[:relation] = field.relation if ['many2one', 'one2many', 'many2many'].include? field.ttype

        @fields[field.name] = specs
      end
    end
  end

end