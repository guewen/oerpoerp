module OerpOerp
  class TargetLine

    def initialize(migration, postponed_task, source_line, setters, before_action, before_save_action, after_action)
      @migration = migration  # FIXME need migration ? maybe only source/target
      @source_line = source_line
      @setters = setters
      @before_action = before_action
      @before_save_action = before_save_action
      @after_action = after_action
      @postponed_tasks = postponed_task

      @target_line = {} # struct ?
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

    def compute_values
      @before_action.call(@source_line, @target_line) unless @before_action.nil?
      run_setters
    end

    def run_setters
      @setters.each do |target_field, setter|
        if setter
          @target_line[target_field.name.to_sym] = setter.call(@source_line, @target_line)
        else
          puts "No setter defined for field #{target_field.name}"
        end
      end
    end

    def display
        # TODO replace puts by logs
        # fixme : does not display cols existing in line and not in source_line
        # fixme move stuff relative to ooor in adapter
        #display_source_line = @source_line.attributes.merge(@source_line.associations)
        #display_source_line.symbolize_keys!
        display_source_line = @source_line.dup
        display_target_line = @target_line.dup
        display_target_line.keys.each { |key| display_source_line[key] = nil unless display_source_line.keys.include? key}

        puts Hirb::Helpers::Table.render [display_source_line.update('' => 'source'), display_target_line.update('' => 'target')], :description => false, :resize => false
        puts "\n"
    end

    def save
      @before_save_action.call(@source_line, @target_line) unless @before_save_action.nil?

      if OPTIONS[:simulation]
        # pretty display
        display
      else
        if existing?
          # TODO provide a unified way to get the id of a line
          update
        else
          insert
        end
      end
      @after_action.call(@source_line, @target_line) unless @after_action.nil?
    end

    private

    def source_line_id
      # FIXME bug with ruby 1.8.7 as all objects respond to #id
      # TODO provide a generic method to give the id of the source. maybe define a default method
      # which give the id overridable in dsl (will let the user choose the field which represent the id)
      @source_line.respond_to?(:id) && @source_line.id || @source_line[:id]
    end

    def update
      @migration.target.update(existing_id, @target_line)
    end

    def insert
      @migration.target.insert(@migration.source.model_name, source_line_id, @target_line)
    end

  end
end