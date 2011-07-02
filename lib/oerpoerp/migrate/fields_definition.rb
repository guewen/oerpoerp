module OerpOerp

  class FieldsDefinition
    attr_reader :source_fields, :target_fields, :matching_fields, :source_only_fields, :target_only_fields, :conflicting_fields

    def initialize(source_fields, target_fields)
      @source_fields = source_fields
      @target_fields = target_fields
      @matching_fields = {}
      @source_only_fields = {}
      @target_only_fields = {}
      @conflicting_fields = {}
    end

    def introspect
      @source_fields.introspect
      @target_fields.introspect
      compare_fields
    end

    # display a nice (not for the moment) output with all infos on fields
    # and DSL examples to import them
    def display_fields

      # TODO redo the display (using HIRB ?))

      puts "\n"
      puts "Fields introspection of models"

      puts "\n"
      puts "Fields only on source :".yellow
      puts "None".green if source_only_fields.empty?
      source_only_fields.each do |field, definition|
        puts "#{field} - #{definition[:type]}".yellow
      end

      puts "\n"
      puts "Fields only on target :".yellow
      puts "None".green if target_only_fields.empty?
      target_only_fields.each do |field, definition|
        puts "#{field} - #{definition[:type]}".yellow
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
        puts "#{field} - #{definition[:type]}".green
      end

      puts "\n"
    end

    private

    def compare_fields
      # compare source and target
      @source_only_fields = {:old_data => {:type => :integer}}
      @matching_fields =
      {:id => {:type => :integer},
       :name => {:type => :string},
       :price => {:type => :float},
       :category => {:type => :many2one, :relation => :product_category}
       }
      @target_only_fields = {:foo => {:type => :integer}}
      @conflicting_fields = ['category']
    end

  end

end