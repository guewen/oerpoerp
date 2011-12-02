module OerpOerp

  module StaticCommon
    attr_accessor :static_fields
    attr_reader :ooor_prefix, :oerp

    def oerp
      false
    end

    def default_iterator
      Proc.new { raise "In static mode, define an iterator with DSL method #data, like: data do [{:id => 1}, {:id => 2}, {:id => 3}] end)" }
    end

    def fields(&fields)
      @static_fields = fields.call
    end

    #def model
    #  @model
    #end

    def get_fields
      raise "Missing static structure of fields in static mode! Define it with DSL method #fields, like: fields do [{:name => 'id', :type => 'integer'}] end" if @static_fields.nil?
      @static_fields.map { |fields| fields.symbolize_keys }
    end

  end

end