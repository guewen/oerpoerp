module OerpOerp

  class Actions

    def self.migrate_lines(migration, lines, line_class=ContainerLine, &block)
      actions = DSL.new(migration, line_class, &block).actions
      actions.migrate_lines(lines)
    end

    class DSL
      # facade class
      # Public methods are available from the DSL .migr files
      # when declaring an action

      attr_reader :actions

      def initialize(migration, line_class, &block)
        @actions = Run.new(migration, line_class)
        instance_eval(&block) if block_given?
      end

      def condition(action=:skip, &block)
        @actions.condition = Struct.new(:action, :block).new(action, block)
      end

      def auto_migrate_fields(options)
        if options.kind_of?(Hash)
          if options[:only]
            @actions.only_fields = options[:only]
            return
          end
          if options[:exclude]
            @actions.skip_fields += options[:exclude]
            return
          end
        end
        unless options
          @actions.only_fields = []
        end
      end

      def set_value(target_field_name, &block)
        @actions.set_value(target_field_name, &block)
      end

      def before(&block)
        @actions.before_action = block
      end

      def before_save(&block)
        @actions.before_save_action = block
      end

      def after(&block)
        @actions.after_action = block
      end

    end

    class Run

      attr_accessor :setters, :condition, :only_fields, :skip_fields,
                    :before_action, :before_save_action, :after_action

      def initialize(migration, line_class)
        @migration = migration
        @line_class = line_class

        @setters = OrderedHash.new  # ordered hash to keep the order defined in the migration files (one could depends of another)

        # used in migration when some action can not be executed (for instance when a line must be assigned to a parent
        # not already created) we add a proc per action to execute at the very end of the model migration
        @postponed_tasks = []

        # auto migrate options
        @only_fields = false
        @skip_fields = [:id]  # do not migrate id !

        @create = false
      end

      def migrate_lines(lines)
        create_default_setters

        @setters.select {|s| s.nil?}.keys.each do |target_field|
          puts "No setter defined for field #{target_field.name}" #TODO log
        end

        lines.each { |line| migrate_line(line) }

        @postponed_tasks.each do |action|
          # beware of the scope, check maybe postponed tasks are not realistic, maybe only use delayed lines execution
          action.call
        end
      end

      def migrate_line(source_line)
        line = @line_class.new(@migration, source_line)

        if !@condition.nil? && @condition.action == :skip && line.execute_action(&@condition.block)
          # log
          puts "Line skipped"
        else
          line.execute_action(&@before_action)

          @setters.each do |target_field, setter_block|
            line.execute_action_on_field(target_field, &setter_block)
          end
          line.execute_action(&@before_save_action)
          line.save
          line.execute_action(&@after_action)
        end
      end

      def set_value(target_field_name, &block)
        field = @migration.models_matching.field(target_field_name.to_s)
        raise "No field named #{target_field_name}!" unless field
        create_field_setter(field, &block)
      end

      private

      def create_field_setter(target_field, &block)
        if block_given?
          @setters[target_field] = block
        else
          # according to field definition, call the good method (copy simple value / many2one...)
          @setters[target_field] = self.send("set_#{target_field.type}", target_field)
        end
      end

      def create_default_setters
        @migration.models_matching.matching_fields.each do |field|
          next if @skip_fields && @skip_fields.map(&:intern).include?(field.name.intern)
          next if @only_fields && !@only_fields.map(&:intern).include?(field.name.intern)
          next if @setters.include? field # already defined in dsl files
          create_field_setter(field)
        end
      end

      def set_simple(target_field)
        # must return a block
        # Proc will be evaluated in the ContainerLine scope
        Proc.new { source_line.send(target_field.name.intern)}
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

      def set_one2one(target_field)
        raise NotImplementedError
      end

      def set_one2many(target_field)
        # skip! we assign many2one fields in a normal case
      end

      def set_many2one(target_field)
        # must return a Proc
        Proc.new do
          # FIXME smarter ways to achieve that
          target_id = nil
          source_id = source_line.send(target_field.name.intern)
          if source_id
            source_id = source_id.id if source_line.is_a? Ooor::OpenObjectResource
            target_id = many2one(source_id)
          end
          target_id
        end
      end

      def set_many2many(target_field)
        # must return a Proc
        #Proc.new do
        #  # FIXME smarter ways to achieve that
        #  target_ids = nil
        #  source_ids = source_line.send(target_field.name.intern)
        #  if source_id
        #    source_id = source_id.id if source_line.is_a? Ooor::OpenObjectResource
        #    target_id = many2many(source_ids)
        #  end
        #  target_ids
        #end
      end

      def set_parent(target_field)
        # TODO
        # used for many2one on the same object
        # how to manage assignation to parents not already imported ?
        # create an array on MigrationBase and fill it with the ids to update ?
        # Maybe fill it with Proc updates ?
        # or fill a dict at each line migration with source_id and status
        # like: {1 => :saved, 2 => :updated, 4 => :skipped, 5 => :retry}
        # must return a block

      end

    end
  end

end