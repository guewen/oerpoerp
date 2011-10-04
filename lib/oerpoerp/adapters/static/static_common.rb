module OerpOerp

  module StaticCommon
    attr_accessor :static_fields
    attr_reader :ooor_prefix, :oerp

    def oerp
      false
    end

    def default_iterator
      Proc.new { raise "In static mode, define an iterator with DSL method : set_source_iterator ( set_source_iterator do [1,2,3] end)" }
    end

    #def model
    #  @model
    #end

    def get_fields
      static_fields.map { |fields| fields.attributes.symbolize_keys }
    end

  end

end