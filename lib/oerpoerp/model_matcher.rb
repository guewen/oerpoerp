module OerpOerp

  class ModelMatch
    attr_reader :matching_fields, :source_only_fields, :target_only_fields, :conflicting_fields

    def initialize(source_model, target_model)
      @matching_fields = []
      @source_only_fields = []
      @target_only_fields = []
      @conflicting_fields = []
      compare(source_model, target_model)
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
      source_only_fields.each do |field|
        puts "#{field.name} - #{field.type}".yellow
      end

      puts "\n"
      puts "Fields only on target :".yellow
      if target_only_fields.empty?
        puts "None".green
      else
        snippets = []
        target_only_fields.each do |field|
          puts "#{field.name} - #{field.type}".yellow
          snippets << "  set_value :#{field.name} do |source_line, target_line|\n" <<
                      "    source_line['bar']\n" <<
                      "  end"
        end
        puts "Snippets :\n"
        snippets.each { |snippet| puts snippet }
      end

      puts "\n"
      puts "Conflicting fields :".red
      puts "None".red if conflicting_fields.empty?
      conflicting_fields.each do |field|
        puts "#{field.name}".red
#        puts "Source : #{source_fields[field][:type]} - Target : #{target_fields[field][:type]} ".red
      end

      puts "\n"
      puts "Matching fields (those ones will automatically be migrated if you do not redefine them in the migration file) :".green
      puts "None".red if matching_fields.empty?
      matching_fields.each do |field|
        puts "#{field.name} - #{field.type} #{field.relation}".green
      end

      puts "\n"
    end

    def field(name)
      (@matching_fields + @conflicting_fields + @source_only_fields + target_only_fields)
        .select {|field| field.name == name}.first
    end

    private

    def compare(source_model, target_model)
      # compare source and target

      @matching_fields = source_model.matching_fields(target_model)
      @conflicting_fields = source_model.conflicting_fields(target_model)

      @source_only_fields = source_model.one_side_fields(target_model)
      @target_only_fields = target_model.one_side_fields(source_model)

    end

  end

end