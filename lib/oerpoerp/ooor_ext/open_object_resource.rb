module Ooor
  class OpenObjectResource < ActiveResource::Base

    def flatten
      fields = associations.merge(attributes)
      fields
    end

    def to_struct
      flatten.to_struct
    end

  end
end