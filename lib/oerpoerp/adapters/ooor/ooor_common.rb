module OerpOerp

  module OoorCommon
    attr_reader :ooor_prefix, :oerp

    def oerp
      @oerp ||= Pooler.get(self.class.proxy, connection_name)
    end

    def default_iterator
      Proc.new { model.all }
    end

    def model
      @model ||= oerp[@model_name]
      @model
    end

    def get_fields
      model.reload_fields_definition if model.fields.empty?
      each_fields = [model.fields,
                     model.many2one_associations,
                     model.one2many_associations,
                     model.many2many_associations,
                     model.polymorphic_m2o_associations]

      all_fields = each_fields.reduce(:merge)

      model_fields = []
      all_fields.each do |name, keys|
        model_fields << {
          :name => name,
          :type => keys['type'],
          :string => keys['string'],
          :relation => keys['relation']
        }
      end

      model_fields
    end

  end

end