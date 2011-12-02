module OerpOerp
  module AdaptersFactory

    module ClassMethods
      attr_reader :proxy_classes, :proxy

      def proxy_for(method, *args, &block)
        proxy_class = self.proxy_classes.find do |klass|
          klass.proxy_for?(method)
        end
        return proxy_class.new(*args, &block) if proxy_class
        nil
      end

      def register_proxy(proxy)
        @proxy = proxy
      end

      def proxy_for?(proxy)
        @proxy == proxy
      end

      def inherited(subclass)
        self.proxy_classes << subclass
      end
    end

    def self.included(host_class)
      host_class.extend(ClassMethods)
    end

    def adapter_options
      @adapter_options ||= OerpOerp::OPTIONS[self.class.proxy]
    end

  end

  module SourceTargetCommon

    attr_reader :model, :connection_name, :model_name

    def model_structure
      return @model_structure if defined? @model_structure
      @model_structure = OerpOerp::OpenERPModel.new(@model_name)
      get_fields.each do |field|
        @model_structure << field
      end
      @model_structure
    end

    def initialize(*args, &block)
      # todo improve
      @connection_name = args.last[:connection]
      instance_eval(&block) if block
    end

    # refactor using DSL facade allowing to use model as setter
    def base_model(name)
      @model_name = name
    end

  end

  class SourceBase
    include AdaptersFactory
    include SourceTargetCommon
    @proxy_classes = []

    attr_reader :data_iterator

    def connection_name
      @connection_name ||= OerpOerp::OPTIONS[self.class.proxy][:default_source_connection]
      @connection_name
    end

    def default_iterator
      # must be a proc containing a object responding to #each
      Proc.new { [] }
    end

    def lines
      block = @data_iterator || default_iterator
      block.call
    end

    # DSL Methods

    def data(&block)
      @data_iterator = block
    end

  end

  class TargetBase
    include AdaptersFactory
    include SourceTargetCommon
    @proxy_classes = []

    def write_source_id(source_model_name, source_id)
      # write in ir_model_data
      raise NotImplementedError "Not implemented on base class"
    end

    def find_by_source_id(source_model_name, source_id, *args)
      # find in ir_model_data
      raise NotImplementedError "Not implemented on base class"
    end

    def connection_name
      @connection_name ||= OerpOerp::OPTIONS[self.class.proxy][:default_target_connection]
      @connection_name
    end

    def insert(source_model_name, source_id, data_record)
      created_id = insert_only(data_record)
      write_ref_source_id(source_model_name, source_id, created_id)
      created_id
    end

    def update(resource_id, data_record)
      raise NotImplementedError "Not implemented on base class"
    end

    private

    def insert_only(data_record)
      # Insert and returns the id of the created record
      raise NotImplementedError "Not implemented on base class"
    end

    def write_ref_source_id(source_model_name, source_id, target_id)
      # already done in the insert with ooor
      #nothing to do here
      raise NotImplementedError "Not implemented on base class"
    end

    def ir_model_data_name(model_name, source_id)
      "#{model_name.gsub('.', '_')}/#{source_id.to_s}"
    end

    def ir_model_data_module
      "oerpoerp/#{OerpOerp::OPTIONS[:name]}"
    end

  end
end