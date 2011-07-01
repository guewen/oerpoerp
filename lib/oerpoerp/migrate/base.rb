module OerpOerp
  class MigrateBase

    attr_accessor :name, :depends
    attr_reader :fields_definition


    def initialize(&block)
      @name = nil
      @depends = []

      @source_method = :ooor
      @target_method = :ooor

      @source_model = nil
      @target_model = nil

      @source_fields = {}
      @target_fields = {}

      @from_iterator = Proc.new {}
      @before_action = Proc.new {}
      @after_action = Proc.new {}

      @source = ProxySource.proxy_for(@source_method)
      @target = ProxyTarget.proxy_for(@target_method)

      @source_fields = ProxyFieldsIntrospection.proxy_for(@source_method)
      @target_fields = ProxyFieldsIntrospection.proxy_for(@target_method)
      @fields_definition = FieldsDefinition.new(@source, @target)
#      @references = ImportReferences.create(@target_method)

      instance_eval(&block) if block
    end

    def initialize_from_file(path)
      instance_eval(File.read(path), path)
    end

    def name(name)
      raise "Name must be a symbol (#{name})" unless name.is_a? Symbol
      @name = name
    end

    def depends(depends)
      raise "Dependencies must be an array (#{depends})" unless depends.is_a? Array
      @depends = depends
    end

    def source_method(method)
      @source_method = method
    end

    def target_method(method)
      @target_method = method
    end

    def source_model(model)
      @source_model = model
    end

    def target_model(model)
      @target_model = model
    end

    def source
      # implement in modules (like SOURCE_OOOR::ProductProduct / SOURCE_DB[:product_product])
      @source_model
    end

    def from_iterator(&block)
      @from_iterator = block
    end

    def before(&block)
      @before_action = block
    end

    def after(&block)
      @after_action = block
    end

    def run_import
      @before_action.call
      @from_iterator.call.each do |from|
        lines_actions.run(from)
      end
      @after_action.call
    end

    def run
      introspect_fields

      # display resume of fields and actions
      # display fields that will be migrated
      # display the ones which are different with exemples of DSL to migrate them
      # display the ones which are only on source or target with examples of DSL to migrate them

      # run import if option is on
      run_import

    end

    def do_lines_actions(&block)
      @lines_actions = MigrateLineBase.new(self, &block)
    end

    private

    def lines_actions
      @lines_actions ||= MigrateLineBase.new(self)
    end

    def introspect_fields
      @fields_definition.introspect
      @fields_definition.display_fields if OPTIONS[:verbose]
    end

  end


  class MigrateLineBase < Hash

    attr_reader :migration

    def initialize(migration, &block)
      @migration = migration
      @before_action = Proc.new {}
      @before_save_action = Proc.new {}
      @setters = OrderedHash.new
      @after_action = Proc.new {}
      instance_eval(&block) if block
    end

    def before(&block)
      @before_action = block
    end

    def before_save(&block)
      @before_save_action = block
    end

    def after(&block)
      @after_action = block
    end

    def set_value(to_field, &block)
      if block_given?
        @setters[to_field] = block
      else
        # according to field definition, call the good method (copy simple value / many2one...)
        field_definition = migration.fields_definition.matching_fields[to_field]
        raise "No #{to_field} found in the fields introspection" unless field_definition
        @setters[to_field] = self.send "set_#{field_definition[:type]}", to_field
      end
    end

    def save
      pp self
    end

    def run(source_line)
      @before_action.call(source_line, self)
      create_default_setters
      @setters.each do |to_field, setter|
        if setter
          self[to_field] = setter.call(source_line, self)
        else
          puts "No setter defined for field #{to_field}"
        end
      end
      @before_save_action.call(source_line, self)
      save
      @after_action.call(source_line, self)
    end

    private

    def create_default_setters
      migration.fields_definition.matching_fields.keys.each do |field|
        unless @setters.keys.include? field
          # fixme do not use block but
          set_value(field)
        end
      end
    end

    def set_integer(to_field)
      # must return a block
      Proc.new { |source_line, target_line| source_line[to_field] }
    end

    def set_float(to_field)
      # must return a block
      Proc.new { |source_line, target_line| source_line[to_field] }
    end

    def set_string(to_field)
      # must return a block
      Proc.new { |source_line, target_line| source_line[to_field] }
    end

    def set_boolean(to_field)
      # must return a block
      Proc.new { |source_line, target_line| source_line[to_field] }
    end

    def set_many2one(to_field)
      # must return a block
      # get relation id using the relation of fields introspection and the
      # class used for the references
    end

    def set_many2many(to_field)
      # must return a block
    end

    def set_parent(to_field)
      # used for many2one on the same object
      # how to manage assignation to parents not already imported ?
      # create an array on MigrationBase and fill it with the ids to update ?
      # Maybe fill it with Proc updates ?
      # must return a block
    end

  end
end