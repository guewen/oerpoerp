module OerpOerp

  require File.dirname(__FILE__) + '/ooor_common'

  class OoorTarget < TargetBase
    include OoorCommon

    register_proxy :ooor

    def find_by_source_id(source_model_name, source_id, *args)
      options = args.extract_options!
      model.find("#{ir_model_data_module}.#{ir_model_data_name(source_model_name, source_id)}", options)
    end

    def find_many2one_by_source_id(many2one_model_name, source_id, *args)
      return false unless source_id
      options = args.extract_options!
      many2one_model = oerp.const_get(many2one_model_name)
      res = many2one_model.find("#{ir_model_data_module}.#{ir_model_data_name(many2one_model_name, source_id)}", options)
      return res.id if res
      raise "No record found for many2one with id #{source_id} on model #{many2one_model_name}"
    end

    #def write_ref_source_id(source_model_name, source_id, target_id)
    #  # write in ir_model_data
    #  ir_data = oerp.const_get('IrModelData').new(
    #      {
    #        :name => ir_model_data_name(source_model_name, source_id),
    #        :module => "oerpoerp/#{source_model_name}",
    #        :res_id => target_id,
    #        :model => @model_name,
    #      }
    #  )
    #end

    def insert(source_model_name, source_id, data_record)

      # TODO do not forget to report the fix on OOOR
      # file open_object_resource.rb, line 364
      # replaced
      # IrModelData.create(:model => self.class.openerp_model, :module => @ir_model_data_id[0], :name=> @ir_model_data_id[1], :res_id => self.id) if @ir_model_data_id
      # self.class.const_get('ir.model.data', context).create(:model => self.class.openerp_model, :module => @ir_model_data_id[0], :name=> @ir_model_data_id[1], :res_id => self.id) if @ir_model_data_id
      # maybe because using prefix
      # Add stuff in data to create ir.model.data reference (ooor create it when ir_model_data_id key is defined in values)
      data_record.merge!({:ir_model_data_id =>
                              [ir_model_data_module,
                               ir_model_data_name(source_model_name, source_id)]})
      super
    end

    def update(resource_id, data_record)
      resource = model.find(resource_id)
      data_record.each do |key, value|
        resource.send "#{key}=", value
      end

      resource.save
      # FIXME replace by a logger
      puts "Record #{resource.name} updated." if OPTIONS[:verbose]
    end

    private

    def insert_only(data_record)
      record = model.new(data_record)
      begin
        record.save
      rescue Exception => error
        # TODO create a logger
        puts "Error when trying to insert data record"
        pp record
        raise
      end
      # FIXME replace by a logger
      puts "Record #{record.name} created with id #{record.id}." if OPTIONS[:verbose]
    end

    def write_ref_source_id(source_model_name, source_id, target_id)
      # already done in the insert with ooor
      #nothing to do here
    end

  end

end