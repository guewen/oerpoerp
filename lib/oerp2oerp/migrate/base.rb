class MigrateBase

  attr_accessor :name, :depends

  def initialize(&block)
    @name = nil
    @depends = []
    @read_method = :ooor
    @write_method = :ooor
    @from_iterator = proc{}
    @before_action = proc{}
    @after_action = proc{}
    instance_eval(&block) if block
  end

  def initialize_from_file(path)
    instance_eval(File.read(path))
  end

  def name(name)
    raise "Name must be a symbol" unless name.is_a? Symbol
    @name = name
  end

  def depends(depends)
    raise "Dependencies must be an array" unless depends.is_a? Array
    @depends = depends
  end

  def read_method(method)
    @read_method = method
  end

  def write_method(method)
    @write_method = method
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
      puts from
    end
    @after_action.call
  end

end


class MigrateLineBase < Hash

end