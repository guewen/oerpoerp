module OerpOerp

  module MigrationDSL


    def initialize_from_file(path)
      instance_eval(File.read(path), path)
    end

    # DSL Methods
    def name(name)
      raise "Name must be a symbol (#{name})" unless name.is_a? Symbol
      @migration_name = name
    end

    def depends(dependencies)
      raise "Dependencies must be an array of symbols (#{dependencies})" unless dependencies.is_a? Array || !dependencies.filter{|d| !d.is_a?(Symbol)}.empty?
      @dependencies = dependencies
    end

    def before(&block)
      @before_action = block
    end

    def after(&block)
      @after_action = block
    end

    def source_with(options={}, &block)
      # method is :ooor, :sequel, :static, ...
      # destination is the key/name (#TODO tbd) to use for the connection
      @source_configuration = [options, block]
    end

    def target_with(options={}, &block)
      # method is :ooor, :sequel, :static, ...
      # destination is the key/name (#TODO tbd) to use for the connection
      @target_configuration = [options, block]
    end
    
    def lines_actions(&block)
      @lines_block = block
    end
  end

end
