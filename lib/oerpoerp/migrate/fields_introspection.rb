module OerpOerp
  class FieldsIntrospection
    attr_reader :source_fields, :target_fields, :matching_fields, :source_only_fields, :target_only_fields, :conflicting_fields

    def initialize(&block)
      @source_fields = {}
      @target_fields = {}
      @matching_fields = {}
      @source_only_fields = {}
      @target_only_fields = {}
      @conflicting_fields = {}
    end

    def introspect
      introspect_source
      introspect_target
      match_fields
    end

    private

    def introspect_source
      @source_fields = {}
    end

    def introspect_target
      @target_fields = {}
    end

    def match_fields
      @matching_fields =
      {:id => {:type => :integer},
       :name => {:type => :string},
       :price => {:type => :float},
       :category => {:type => :many2one, :relation => :product_category}
       }
    end

  end

end