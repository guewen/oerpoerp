module OerpOerp
  class TargetLine

    def initialize(source_line, setters, before_action, before_save_action, after_action)
      @source_line = source_line
      @setters = setters
      @before_action = before_action
      @before_save_action = before_save_action
      @after_action = after_action

      @target_line = {} # struct ?
    end

    def existing?
      # TODO check in oerp if the id of the source line exist in the ref ids
      false
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
          update(@source_line.id)
        else
          insert
        end
      end
      @after_action.call(@source_line, @target_line) unless @after_action.nil?
    end

    private

    def update(id)
      raise NotImplementedError "Update not already implemented"
    end

    def insert
      raise NotImplementedError "Insert not already implemented"
    end

  end
end