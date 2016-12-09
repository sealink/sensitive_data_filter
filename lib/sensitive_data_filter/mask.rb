# frozen_string_literal: true
module SensitiveDataFilter
  module Mask
    module_function def mask(value)
      SensitiveDataFilter.enabled_types.inject(value) { |acc, elem| elem.mask acc }
    end

    module_function def mask_hash(hash)
      hash.map.with_object({}) { |(key, value), result|
        result[key] = mask(value)
      }
    end
  end
end
