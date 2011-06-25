module OerpOerp
  class MigrateBase

    attr_accessor :name, :depends
    attr_reader :fields_definition


    def initialize(&block)
      @name = nil
      @depends = []
      @source_reader = :ooor
      @target_writer = :ooor
      @source_model = nil
      @target_model = nil
      @from_iterator = proc{}
      @before_action = proc{}
      @after_action = proc{}
      @fields_definition = {}
      instance_eval(&block) if block
    end

    def initialize_from_file(path)
      instance_eval(File.read(path), path)
    end

    def name(name)
      raise "Name must be a symbol (#{name})" unless name.is_a? Symbol
      @name = name
    end

    def depends(depends)
      raise "Dependencies must be an array (#{depends})" unless depends.is_a? Array
      @depends = depends
    end

    def source_reader(method)
      @source_reader = method
    end

    def target_writer(method)
      @target_writer = method
    end

    def source_model(model)
      @source_model = model
    end

    def target_model(model)
      @target_model = model
    end

    def source
      # implement in modules (like SOURCE_OOOR::ProductProduct / SOURCE_DB[:product_product])
      @source_model
    end

    def from_iterator(&block)
      @from_iterator = block
    end

    def before(&block)
      @before_action = block
    end

    def after(&block)
      @after_action = block
    end

    def run
      introspect_fields
      @before_action.call
      @from_iterator.call.each do |from|
        @lines_actions.run(from)
      end
      @after_action.call
    end

    def lines_actions(&block)
      @lines_actions = MigrateLineBase.new(self, &block)
    end

    def introspect_fields
      # automatic introspection
      @fields_definition =
          {:id => {:type => :integer},
           :name => {:type => :string},
           :price => {:type => :float},
           :category => {:type => :many2one, :relation => :product_category}
           }
    end

  end


  class MigrateLineBase < Hash

    attr_reader :migration

    def initialize(migration, &block)
      @migration = migration
      @before_action = proc{}
      @before_save_action = proc{}
      @setters = OrderedHash.new
      @after_action = proc{}
      instance_eval(&block) if block
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

    def set_integer(to_field)
      # must return a block
      Proc.new { |source_line| source_line[to_field].to_i }
    end

    def set_float(to_field)
      # must return a block
      Proc.new { |source_line| source_line[to_field].to_f }
    end

    def set_string(to_field)
      # must return a block
      Proc.new { |source_line| source_line[to_field].to_s }
    end

    def set_boolean(to_field)
      # must return a block
      Proc.new { |source_line| source_line[to_field] }
    end

    def set_many2one(to_field)
      # must return a block
    end

    def set_value(to_field, &block)
      if block_given?
        @setters[to_field] = block
      else
        # according to field defintion, call the good method (copy simple value / many2one...)
        field_definition = migration.fields_definition[to_field]
        raise "No #{to_field} found in the fields introspection" unless field_definition
        @setters[to_field] = self.send "set_#{field_definition[:type]}", to_field
      end
    end

    def create_default_setters
      migration.fields_definition.keys.each do |field|
        unless @setters.keys.include? field
          # fixme do not use block but
          set_value(field)
        end
      end
    end

    def save

    end

    def run(source_line)
      @before_action.call(source_line)
      create_default_setters
      @setters.each do |to_field, setter|
        if setter
          self[to_field] = setter.call(source_line)
        else
          puts "No setter defined for field #{to_field}"
        end
      end
      @before_save_action.call(source_line)
      save
      @after_action.call(source_line)
      pp self
    end

  end
end