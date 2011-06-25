class MigrateBase

  attr_accessor :name, :depends

  def initialize(&block)
    @name = nil
    @depends = []
    @source_reader = :ooor
    @target_writer = :ooor
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
    @before_action.call
    @from_iterator.call.each do |from|
      @lines_actions.run(from)
    end
    @after_action.call
  end

  def lines_actions(&block)
    @lines_actions = MigrateLineBase.new(&block)
  end

  def introspect_fields

  end

end


class MigrateLineBase < Hash

  def initialize(&block)
    @before_action = proc{}
    @setters = {}
    @after_action = proc{}
    instance_eval(&block) if block
  end

  def before(&block)
    @before_action = block
  end

  def after(&block)
    @after_action = block
  end

  def set_value(to_field, &block)
    @setters[to_field] = block
  end

  def run(from_line)
    @before_action.call(from_line)
    @setters.each do |to_field, setter|
      self[to_field] = setter.call(from_line)
    end
    @after_action.call(from_line)
    pp self
  end

end