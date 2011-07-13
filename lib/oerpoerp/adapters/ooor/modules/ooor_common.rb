module OerpOerp

  module OoorCommon
    attr_reader :ooor_prefix

    def default_iterator
      Proc.new { model.all }
    end

    def model
      model_ooor = Ooor::OpenObjectResource.class_name_from_model_key(@model_name)
      @model ||= ooor_prefix.const_get(model_ooor)
    end

    def fields
      return @fields if defined? @fields
      @fields = {}
      ooor_prefix::IrModelFields.find(:all, :domain => [['model', '=', @model_name]],
                         :fields => ['ttype', 'relation', 'name']).each do |field|
        specs = {}
        specs[:ttype] = field.ttype
        specs[:relation] = field.relation if ['many2one', 'one2many', 'many2many'].include? field.ttype

        @fields[field.name] = specs
      end
      @fields
    end

    private

    def ooor_prefix_name
      @ooor_prefix_name ||= self.class.connection_from.to_s.capitalize
    end

    def ooor_prefix
      @ooor_prefix ||= OerpOerp.const_get(ooor_prefix_name)
    end

  end

end