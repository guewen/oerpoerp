module OerpOerp

  module OoorCommon
    attr_reader :ooor_prefix, :oerp

    def oerp
      @oerp = Pooler.get(self.class.proxy, self.class.connection_from)
      @oerp
    end

    def default_iterator
      Proc.new { model.all }
    end

    def model
      @model ||= oerp[@model_name]
    end

    def fields
      return @fields if defined? @fields
      @fields = {}
      oerp['ir.model.fields'].find(:all, :domain => [['model', '=', @model_name]],
                                   :fields => ['ttype', 'relation', 'name']).each do |field|
        specs = {}
        specs[:ttype] = field.ttype
        specs[:relation] = field.relation if ['many2one', 'one2many', 'many2many'].include? field.ttype

        @fields[field.name] = specs
      end
      @fields
    end

  end

end