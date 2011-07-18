module OerpOerp
  class MigrateBase

    attr_accessor :name, :depends
    attr_reader :fields_definition, :source, :target


    def initialize(&block)
      @name = nil
      @depends = []

      # default method if not overriden in migration files is ooor
      @source_method = :ooor
      @target_method = :ooor

      @from_iterator = nil
      @before_action = Proc.new {}
      @after_action = Proc.new {}

      @source = SourceBase.proxy_for(@source_method)
      @target = TargetBase.proxy_for(@target_method)

      @fields_definition = FieldsAnalyzer.new

      @lines_block = Proc.new {}

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
      @source.model_name = model
    end

    def target_model(model)
      @target.model_name = model
    end

    def set_source_iterator(&block)
      @source_iterator = block
    end

    def source_iterator
      @source_iterator ||= @source.default_iterator
      @source_iterator
    end

    def before(&block)
      @before_action = block
    end

    def after(&block)
      @after_action = block
    end

    def do_operations
      @before_action.call unless OPTIONS[:simulation]
      source_iterator.call.each do |from|
        lines_actions = MigrateLineBase.new(self, from, &@lines_block)
        lines_actions.migrate_line
      end
      @after_action.call unless OPTIONS[:simulation]
    end

    def run
      puts "Starting import of #{@name} migration file from #{@source_model} model to #{@target_model} model"
      introspect_fields
      puts "Starting lines import"
      do_operations
    end

    def lines_actions(&block)
      @lines_block = block
    end

    private

    def introspect_fields
      @fields_definition.compare(@source.fields, @target.fields)
      @fields_definition.display if OPTIONS[:verbose]
    end

  end


  class MigrateLineBase

    attr_reader :migration, :source_line

    def initialize(migration, source_line, &block)
      @migration = migration
      @source_line = source_line
      @before_action = Proc.new {}
      @before_save_action = Proc.new {}
      @setters = OrderedHash.new  # ordered hash to keep the order defined in the migration files (one could depends of another)
      @after_action = Proc.new {}

      # auto migrate options
      @only_fields = false
      @skip_fields = [:id]  # do not migrate id !

      @create = false

      @line = {}

      instance_eval(&block) if block
    end

    def source
      @migration.source
    end

    def target
      @migration.target
    end

    def migrate_line
      @before_action.call(source_line, @line) unless OPTIONS[:simulation]
      create_default_setters
      run_setters(source_line)
      @before_save_action.call(source_line, @line) unless OPTIONS[:simulation]
      save
      @after_action.call(source_line, @line) unless OPTIONS[:simulation]
    end

    def run_setters(source_line)
      @setters.each do |target_field, setter|
        if setter
          @line[target_field.to_sym] = setter.call(source_line, @line)
        else
          puts "No setter defined for field #{target_field}"
        end
      end
    end

    ##### DSL methods #####
    def before(&block)
      @before_action = block
    end

    def before_save(&block)
      @before_save_action = block
    end

    def after(&block)
      @after_action = block
    end

    def auto_migrate_fields(options)
      if options.kind_of?(Hash)
        if options[:only]
          @only_fields = options[:only]
          return
        end
        if options[:exclude]
          @skip_fields += options[:exclude]
          return
        end
      end
      unless options
        @only_fields = []
      end
    end

    def set_value(target_field, &block)
      field_sym = target_field.to_sym
      if block_given?
        @setters[field_sym] = block
      else
        # according to field definition, call the good method (copy simple value / many2one...)
        field_definition = migration.fields_definition.matching_fields[target_field]
        raise "No #{target_field} found in the fields introspection" unless field_definition
        @setters[field_sym] = self.send "set_#{field_definition[:ttype]}", field_sym
      end
    end

    private

    def create_default_setters
      migration.fields_definition.matching_fields.keys.each do |field|
        next if @skip_fields && @skip_fields.include?(field)
        next if @only_fields && !@only_fields.include?(field)
        next if @setters.keys.include?(field)
        set_value(field)
      end
    end

    def set_simple(target_field)
      # must return a block
      Proc.new { |source_line, target_line| source_line.send(target_field) }
    end

    alias_method :set_integer, :set_simple
    alias_method :set_integer_big, :set_simple
    alias_method :set_float, :set_simple
    alias_method :set_char, :set_simple
    alias_method :set_text, :set_simple
    alias_method :set_selection, :set_simple
    alias_method :set_boolean, :set_simple
    alias_method :set_date, :set_simple
    alias_method :set_datetime, :set_simple
    alias_method :set_binary, :set_simple

    def set_simple(target_field)
      # must return a block
      raise NotImplementedError
    end

    def set_one2one(target_field)
      raise NotImplementedError
    end

    def set_one2many(target_field)
      # skip! we assign many2one in a normal case
    end

    def set_many2one(target_field)
      # must return a block
      # get relation id using the relation of fields introspection and the
      # class used for the references
      # create a table to store old and new id (module oerpoerp in oerp)
      # TODO
      Proc.new { |source_line, target_line| 1 }
    end

    def set_many2many(target_field)
      # must return a block
      # TODO
    end

    def set_parent(target_field)
      # TODO
      # used for many2one on the same object
      # how to manage assignation to parents not already imported ?
      # create an array on MigrationBase and fill it with the ids to update ?
      # Maybe fill it with Proc updates ?
      # must return a block
    end

    def save

      if OPTIONS[:simulation]
        # pretty display
        # TODO replace puts by logs
        # fixme : does not display cols existing in line and not in source_line
        # fixme move stuff relative to ooor in adapter
        display_source_line = @source_line.attributes.merge(@source_line.associations)
        display_source_line.symbolize_keys!
        display_line = @line.dup
        @line.keys.each { |key| display_source_line[key] = nil unless display_source_line.keys.include? key}

        puts Hirb::Helpers::Table.render [display_source_line.update('' => 'source'), display_line.update('' => 'target')], :description => false, :resize => false
        puts "\n"
      else
        target.save(@line)
      end
    end


  end
end