module OerpOerp

  class FieldsAnalyzer    # TODO: rename to ModelComparator? take 2 models
    attr_reader :matching_fields, :source_only_fields, :target_only_fields, :conflicting_fields

    def initialize
      @matching_fields = {}
      @source_only_fields = {}
      @target_only_fields = {}
      @conflicting_fields = {}
    end

    # display a nice (not for the moment) output with all infos on fields
    # and DSL examples to import them
    def display

      # TODO redo the display (using HIRB ?))

      puts "\n"
      puts "Fields introspection of models"

      puts "\n"
      puts "Fields only on source :".yellow
      puts "None".green if source_only_fields.empty?
      source_only_fields.each do |field, definition|
        puts "#{field} - #{definition[:ttype]}".yellow
      end

      puts "\n"
      puts "Fields only on target :".yellow
      puts "None".green if target_only_fields.empty?
      target_only_fields.each do |field, definition|
        puts "#{field} - #{definition[:ttype]}".yellow
        puts "    set_value(:#{field}) do |source_line, target_line|\n" <<
             "      source_line['bar']\n" <<
             "    end"
      end

      puts "\n"
      puts "Conflicting fields :".red
      puts "None".red if conflicting_fields.empty?
      conflicting_fields.each do |field|
        puts "#{field}".red
#        puts "Source : #{source_fields[field][:type]} - Target : #{target_fields[field][:type]} ".red
      end

      puts "\n"
      puts "Matching fields (those ones will automatically be migrated if you do not redefine them in the migration file) :".green
      puts "None".red if matching_fields.empty?
      matching_fields.each do |field, definition|
        puts "#{field} - #{definition[:ttype]} #{definition[:relation]}".green
      end

      puts "\n"
    end

    def compare(source_fields, target_fields)
      # compare source and target
      @source_only_fields = one_side_fields(source_fields, target_fields)
      @target_only_fields = one_side_fields(target_fields, source_fields)

      @matching_fields = {}
      @conflicting_fields = []
      same_fields_keys = source_fields.keys - @source_only_fields.keys
      same_fields_keys.each do |field|
        if source_fields[field] == target_fields[field]
          @matching_fields[field] = source_fields[field]
        else
          @conflicting_fields << field
        end
      end

    end

    private

    def one_side_fields(left_fields, right_fields)
      only_left = {}
      (left_fields.keys - right_fields.keys).each { |field| only_left[field] = left_fields[field] }
      only_left
    end

  end

end