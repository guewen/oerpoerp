module OerpOerp
  class MigrationCore

    include OerpOerp::MigrationDSL

    attr_accessor :migration_name, :dependencies, :source, :target, :before_block, :after_block, :lines_block
    attr_reader :models_matching
    attr_reader :source_configuration, :target_configuration

    class << self
      def initialize
        @migrations = []
      end
    end

    def self.sort!
      # sort by migration dependencies. check sort signature
    end

    def self.included(host_class)
      @migrations << self
    end

    def initialize(source_class=nil, target_class=nil, actions_class=nil, &block)
      @source_class = source_class || OerpOerp::SourceBase
      @target_class = target_class || OerpOerp::TargetBase
      @actions_class = actions_class || OerpOerp::MigrationActions

      yield self if block_given?
    end

    def set_source_iterator(&block)
      @source_iterator = block
    end

    def source
      return @source unless @source.nil?
      method = @source_configuration[0][:method]
      destination = @source_configuration[0][:connection]
      block = @source_configuration[1]
      @source = @source_class.proxy_for(method, destination, &block)
      @source
    end

    def target
      return @target unless @target.nil?
      method = @target_configuration[0][:method]
      destination = @target_configuration[0][:connection]
      block = @target_configuration[1]
      @target = @target_class.proxy_for(method, destination, &block)
      @target
    end

    def line_actions
      return @line_actions if @line_actions.defined?
      @line_actions = @actions_class.new
      @line_actions
    end

    def do_operations
      @before_action.call unless @before_action or OPTIONS[:simulation]
      source.lines.each do |from|
        line_actions.migrate_line # todo
      end
      @after_action.call unless @after_action or OPTIONS[:simulation]
    end

    def run
      puts "Starting import of #{@name} migration file from #{@source_model} model to #{@target_model} model"
      introspect_models
      puts "Starting lines import"
      @actions = @actions_class.new(self, &@lines_block)
      do_operations
    end

    private

    def introspect_models
      @models_matching = OerpOerp::ModelMatch.new(source.model_structure, target.model_structure)
      @models_matching.display if OPTIONS[:verbose]
    end

  end

end