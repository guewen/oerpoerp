module OerpOerp

  module OoorCommon
    attr_reader :ooor_prefix, :oerp

    def oerp
      @oerp ||= Pooler.get(self.class.proxy, self.class.connection_from)
    end

    def default_iterator
      Proc.new { model.all }
    end

    def model
      @model ||= oerp[@model_name]
    end

    def get_fields
      ir_model_fields = oerp['ir.model.fields'].find(:all,
                                                     :domain => [['model', '=', @model_name]],
                                                     :fields => ['ttype', 'relation', 'name'])
      ir_model_fields.map { |fields| fields.attributes.symbolize_keys }
    end

  end

end