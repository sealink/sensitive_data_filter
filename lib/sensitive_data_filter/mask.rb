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
      hash.map { |key, value| mask_key_value(key, value) }.to_h
    end

    module_function def mask_key_value(key, value)
      masked_key = mask(key)
      return [masked_key, value] if SensitiveDataFilter.whitelisted_key? key
      [masked_key, mask(value)]
    end
  end
end
