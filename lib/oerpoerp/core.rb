module OerpOerp

  class Migration

    class << self
      attr_reader :migrations
    end

    @migrations = []

    def self.add(path)
      migration = DSL.initialize_from_file(path).migration
      @migrations << migration
      migration
    end

    def self.sort!
      # sort by migration dependencies. check sort signature
      @migrations
    end

    class DSL

      attr_reader :migration

      def self.initialize_from_file(path)
        migration = new.initialize_from_file(path)
        migration
      end

      def initialize_from_file(path)
        @migration = Core.new
        instance_eval(File.read(path), path)
        self
      end

      # DSL Methods
      def name(name)
        raise "Name must be a symbol (#{name})" unless name.is_a? Symbol
        @migration.name = name
      end

      def dependencies(dependencies)
        pp dependencies
        dependencies = [dependencies] unless dependencies.is_a? Array
        raise "Dependencies must be an array of symbols (#{dependencies})" unless dependencies.select { |d| !d.is_a?(Symbol) }.empty?
        @migration.dependencies = dependencies
      end

      def before(&block)
        @migration.before_action = block
      end

      def after(&block)
        @migration.after_action = block
      end

      def source_is(options={}, &block)
        # method is :ooor, :sequel, :static, ...
        # destination is the key/name (#TODO tbd) to use for the connection
        method = options.delete(:method)
        @migration.source_connection(method, options, &block)
      end

      def target_is(options={}, &block)
        # method is :ooor, :sequel, :static, ...
        # destination is the key/name (#TODO tbd) to use for the connection
        method = options.delete(:method)
        @migration.target_connection(method, options, &block)
      end

      def actions(&block)
        @migration.actions_block = block
      end
            
    end

    class Core
      attr_accessor :name, :dependencies, :before_action, :after_action, :actions_block,
                    :source_configuration, :target_configuration, :source_iterator
      attr_reader :models_matching, :source, :target

      def initialize(source_class=SourceBase, target_class=TargetBase, actions_class=Actions)
        @source_class = source_class
        @target_class = target_class
        @actions_class = actions_class
      end

      def source_connection(method, options, &block)
        return @source unless @source.nil?
        @source = @source_class.proxy_for(method, options, &block)
        @source
      end

      def target_connection(method, options, &block)
        return @target unless @target.nil?
        @target = @target_class.proxy_for(method, options, &block)
        @target
      end

      def run
        puts "Starting import of #{@name} migration file from #{@source_model} model to #{@target_model} model"
        introspect_models
        puts "Starting lines import"
        do_actions
      end

      private

      def do_actions
        @before_action.call unless @before_action.nil? or OPTIONS[:simulation]
        @actions_class.migrate_lines(self, @source.lines, &actions_block)
        @after_action.call unless @after_action.nil? or OPTIONS[:simulation]
      end

      def introspect_models
        @models_matching = ModelMatch.new(@source.model_structure, @target.model_structure)
        @models_matching.display if OPTIONS[:verbose]
      end
      
    end

  #class MigrationCore
  #
  #  attr_accessor :migration_name, :dependencies, :source, :target, :before_block, :after_block, :lines_block
  #  attr_reader :models_matching
  #  attr_reader :source_configuration, :target_configuration
  #
  #
  #
  #
  #end
  end
end