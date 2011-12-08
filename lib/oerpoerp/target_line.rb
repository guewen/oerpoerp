module OerpOerp
  class ContainerLine

    # refactor: this class should be very limited, scope visible from setters (source_line, target_line, source, target ?)
    # setters, before, after action etc + write save should be done in actions in the scope of an instance line
    attr_reader :migration, :source_line, :target_line, :postponed_tasks
    
    alias_method :sl, :source_line
    alias_method :tl, :target_line

    def initialize(migration, source_line)
      @migration = migration  # FIXME need migration ? maybe only source/target

      # use Struct for source line for convenience
      # getters with dot notation and [] using symbols or strings]
      # for ooor source, we keep the original object to keep the chain dot notation
      case source_line
        when Ooor::OpenObjectResource
          @source_line = source_line
        else
         @source_line = source_line.to_struct
      end

      @target_line = {} # Struct ?
    end

    def target
      migration.target
    end

    def source
      migration.source
    end

    def existing_id
      return @existing_id if defined? @existing_id
      # TODO specific ooor... make generic
      resource = @migration.target.find_by_source_id(@migration.source.model_name, source_line_id, :fields => ['id'])
      @existing_id = resource.id if resource
      @existing_id
    end

    def existing?
      # TODO check in oerp if the id of the source line exist in the ref ids
      existing_id && true || false
    end

    def execute_action(&block)
      result = block_given? ? instance_eval(&block) : nil
      result
    end

    def execute_action_on_field(field, &block)
      target_line[field.name.to_sym] = execute_action(&block)
      target_line[field.name.to_sym]
      # target struct version
      #target_line.send("#{field.to_sym}=", execute_action(&block))
    rescue Exception => e
      raise "Failed to assign a value to field #{field.name} (#{field.string}) with error : #{e}"
    end

    def display
        # TODO refactor and replace puts by logs
        # fixme : does not display cols existing in line and not in source_line
        # fixme move stuff relative to ooor in adapter
        #display_source_line = @source_line.attributes.merge(@source_line.associations)
        #display_source_line.symbolize_keys!
        display_source_line = source_line.to_hash
        display_target_line = target_line.dup
        columns = display_target_line.keys
        columns.each { |key| display_source_line[key.to_sym] = nil unless display_source_line.include? key.to_sym}

        puts Hirb::Helpers::Table.render [display_source_line.update('' => 'source'), display_target_line.update('' => 'target')], :description => false, :resize => false
        puts "\n"
    end

    def save
        # pretty display
      display if OPTIONS[:verbose]
      unless OPTIONS[:simulation]
        if existing?
          # TODO provide a unified way to get the id of a line
          update
        else
          insert
        end
      end
    rescue Exception => e
      # log
      puts target_line
      raise
    end

    private

    def many2one(other_id_on_source)
      # must returns the id of the resource on target
      target.find_many2one_by_source_id(migration.source.model_name, other_id_on_source)
    end

    def many2many(other_ids_on_source)
      # must returns the ids of the resource on target
    end

    def one2many(other_ids_on_source)
      # must returns the ids of the resource on target
    end

    def source_line_id
      @source_line.id
    end

    def update
      @migration.target.update(existing_id, @target_line)
    end

    def insert
      @migration.target.insert(@migration.source.model_name, source_line_id, @target_line)
    end

  end
end