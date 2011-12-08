module Ooor
  class OpenObjectResource < ActiveResource::Base

    def flatten
      fields = associations.merge(attributes)
      fields
    end

    def to_hash
      flatten.symbolize_keys!
    end

    def to_struct
      # we lose the chain dot notation, only one level of data
      flatten.to_struct
    end

    def [](field)
      send field.intern
    end
  end
end