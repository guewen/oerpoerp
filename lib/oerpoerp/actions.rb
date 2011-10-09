module OerpOerp
  class MigrationActions

    attr_accessor :migration_name, :dependencies, :before_action, :before_save_action, :after_action, :setters, :migration_source, :migration_target
    attr_reader :migration

    def initialize(migration, &block)
      @migration = migration

      @setters = OrderedHash.new  # ordered hash to keep the order defined in the migration files (one could depends of another)

      # used in migration when some action can not be executed (for instance when a line must be assigned to a parent
      # not already created) we add a proc per action to execute at the very end of the model migration
      @postponed_actions = []

      # auto migrate options
      @only_fields = false
      @skip_fields = [:id]  # do not migrate id !

      @create = false

      instance_eval(&block) if block
    end

    def migrate_lines(lines)
      lines.each { |line| migrate_line(line) }
      
      @postponed_actions.each do |action|
        action.call
      end
    end

    def migrate_line(source_line)
      line = {}
      @before_action.call(source_line, line) unless @before_action or OPTIONS[:simulation]
      create_default_setters
      line = run_setters(source_line, line)
      @before_save_action.call(source_line, line) unless @before_save_action or OPTIONS[:simulation]
      save(source_line, line)
      @after_action.call(source_line, line) unless @after_action or OPTIONS[:simulation]
    end

    def run_setters(source_line, target_line)
      @setters.each do |target_field, setter|
        if setter
          target_line[target_field.name.to_sym] = setter.call(source_line, target_line)
        else
          puts "No setter defined for field #{target_field}"
        end
      end
      target_line
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

    def set_value(target_field_name, &block)
      field_sym = target_field_name.to_sym

      field = migration.models_matching.field(field_sym)
      raise "No field named #{target_field_name}!" unless field
      create_field_setter(field, &block)
    end

    private

    def create_field_setter(target_field, &block)
      if block_given?
        @setters[target_field] = block
      else
        # according to field definition, call the good method (copy simple value / many2one...)
        @setters[target_field] = self.send "set_#{target_field.ttype}", target_field
      end
    end

    def create_default_setters
      migration.models_matching.matching_fields.each do |field|
        next if @skip_fields && @skip_fields.include?(field.name)
        next if @only_fields && !@only_fields.include?(field.name)
        next if @setters.keys.include? field # already defined in dsl files
        create_field_setter(field)
      end
    end

    def set_simple(target_field)
      # must return a block
      # todo adapt to different methods (ooor, sequel, dict, ...), using modules ?
      Proc.new { |source_line, target_line| source_line[target_field.name] }
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

    def before(&block)
      @before_action = block
    end

    def before_save(&block)
      @before_save_action = block
    end

    def after(&block)
      @after_action = block
    end

    def display_lines(source_line, target_line)
        # TODO replace puts by logs
        # fixme : does not display cols existing in line and not in source_line
        # fixme move stuff relative to ooor in adapter
        #display_source_line = @source_line.attributes.merge(@source_line.associations)
        #display_source_line.symbolize_keys!
        display_source_line = source_line.dup
        display_target_line = target_line.dup
        display_target_line.keys.each { |key| display_source_line[key] = nil unless display_source_line.keys.include? key}

        puts Hirb::Helpers::Table.render [display_source_line.update('' => 'source'), display_target_line.update('' => 'target')], :description => false, :resize => false
        puts "\n"
    end

    def save(source_line, target_line)
      # replace by target.insert or target.update called from migration after update of the line

      if OPTIONS[:simulation]
        # pretty display
        display_lines(source_line, target_line)
      else
        raise NotImplementedError "Save not already implemented"
        #target.save(target_line)
      end
    end

  end
end