# frozen_string_literal: true
require 'credit_card_validations'

module SensitiveDataFilter
  module Types
    module CreditCard
      SEPARATORS      = /[\s-]/
      SEPRS           = SEPARATORS.source + '+'
      CARD_16_DIGITS  = /\d{4}#{SEPRS}\d{4}#{SEPRS}\d{4}#{SEPRS}\d{4}/
      CARD_13_DIGITS  = /\d{3}#{SEPRS}\d{3}#{SEPRS}\d{3}#{SEPRS}\d#{SEPRS}\d{3}/
      CARD_14_DIGITS  = /\d{4}#{SEPRS}\d{6}#{SEPRS}\d{4}/
      CARD_15_DIGITS  = /\d{4}#{SEPRS}\d{6}#{SEPRS}\d{5}/
      CARD            = /
                            #{CARD_16_DIGITS.source}
                          | #{CARD_13_DIGITS.source}
                          | #{CARD_14_DIGITS.source}
                          | #{CARD_15_DIGITS.source}
                          |
                        /x
      CATCH_ALL_SEPRS = SEPARATORS.source + '*'
      CATCH_ALL       = /(?:\d#{CATCH_ALL_SEPRS}?){13,16}/
      FILTERED        = '[FILTERED]'

      module_function def valid?(number)
        return false unless number.is_a? String
        CreditCardValidations::Detector.new(number.gsub(SEPARATORS, '')).brand.present?
      end

      module_function def scan(value)
        return [] unless value.is_a? String
        [CARD, CATCH_ALL]
          .flat_map { |pattern| value.scan(pattern) }.uniq
          .select { |card| valid?(card) }
      end

      module_function def mask(value)
        return value unless value.is_a? String
        scan(value).inject(value) { |acc, elem| acc.gsub(elem, FILTERED) }
      end
    end
  end
end
