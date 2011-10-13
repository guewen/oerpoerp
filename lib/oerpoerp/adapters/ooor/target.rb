module OerpOerp

  require File.dirname(__FILE__) + '/ooor_common'

  class OoorTarget < TargetBase
    include OoorCommon

    register_proxy :ooor

    def find_by_source_id(source_model_name, source_id, *args)
      options = args.extract_options!
      model.find("#{ir_model_data_module}.#{ir_model_data_name(source_model_name, source_id)}", options)
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
    end

    private

    def insert_only(data_record)
      # TODO create ir_model_data with ooor (add ir_model_data in data_record)
      record = model.new(data_record)
      begin
        record.save
      rescue Exception => error
        # TODO create a logger
        puts "Error when trying to insert data record"
        pp record
        raise
      end
    end

    def write_ref_source_id(source_model_name, source_id, target_id)
      # already done in the insert with ooor
      #nothing to do here
    end

  end

end