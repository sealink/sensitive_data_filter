# frozen_string_literal: true
module SensitiveDataFilter
  module Mask
    module_function def mask(value)
      return mask_array(value) if value.is_a? Array
      return mask_hash(value) if value.is_a? Hash
      SensitiveDataFilter.enabled_types.inject(value) { |acc, elem| elem.mask acc }
    end

    module_function def mask_array(array)
      array.map { |element| mask(element) }
    end

    module_function def mask_hash(hash)
      hash.map { |key, value| [mask(key), mask(value)] }.to_h
    end
  end
end
