# frozen_string_literal: true
require 'credit_card_validations'

module SensitiveDataFilter
  module Types
    module CreditCard
      SEPARATORS = /[\s-]/
      SEPRS      = SEPARATORS.source + '*'
      LENGTHS    = (11..19)
      CARD       = Regexp.new(
        LENGTHS.map { |length| /(?=(\b(?:\d#{SEPRS}){#{length - 1}}\d\b)?)/.source }.join
      )
      FILTERED = '[FILTERED]'

      module_function def valid?(number)
        return false unless number.is_a? String
        CreditCardValidations::Detector.new(number.gsub(SEPARATORS, '')).brand.present?
      end

      module_function def scan(value)
        return [] unless value.is_a? String
        value.scan(CARD).flatten.compact.select { |card| valid?(card) }
      end

      module_function def mask(value)
        return value unless value.is_a? String
        scan(value).inject(value) { |acc, elem| acc.gsub(elem, FILTERED) }
      end
    end
  end
end
