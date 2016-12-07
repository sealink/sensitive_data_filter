# frozen_string_literal: true
module SensitiveDataFilter
  module Types
    module CreditCard
      SEPARATORS     = /[ -]/
      SEPRS          = SEPARATORS.source + '*'
      CARD_16_DIGITS = /\d{4} #{SEPRS} \d{4} #{SEPRS} \d{4} #{SEPRS} \d{4}/
      CARD_13_DIGITS = /\d{3} #{SEPRS} \d{3} #{SEPRS} \d{3} #{SEPRS} \d #{SEPRS} \d{3}/
      CARD_14_DIGITS = /\d{4} #{SEPRS} \d{6} #{SEPRS} \d{4}/
      CARD_15_DIGITS = /\d{4} #{SEPRS} \d{6} #{SEPRS} \d{5}/
      CARD           = /
                      (?<!\d)(?:
                          #{CARD_16_DIGITS.source}
                        | #{CARD_13_DIGITS.source}
                        | #{CARD_14_DIGITS.source}
                        | #{CARD_15_DIGITS.source}
                      )(?!\d)
                    /x
      FILTERED = '[FILTERED]'

      module_function def valid?(number)
        return false unless number.is_a? String
        return false unless number.match CARD
        Luhn.new(number.gsub(SEPARATORS, '')).valid?
      end

      module_function def scan(value)
        return [] unless value.is_a? String
        value.scan(CARD).select { |card| valid?(card) }
      end

      module_function def mask(value)
        return value unless value.is_a? String
        scan(value).inject(value) { |acc, elem| acc.gsub(elem, FILTERED) }
      end

      # Adapted from https://github.com/rolfb/luhn-ruby/blob/master/lib/luhn.rb
      class Luhn
        def initialize(number)
          @number = number
        end

        def valid?
          numbers = split_digits(@number)
          numbers.last == checksum(numbers[0..-2].join)
        end

        private

        def checksum(number)
          products = luhn_doubled(number)
          sum      = products.inject(0) { |acc, elem| acc + sum_of(elem) }
          checksum = 10 - (sum % 10)
          checksum == 10 ? 0 : checksum
        end

        def luhn_doubled(number)
          numbers = split_digits(number).reverse
          numbers.map.with_index { |n, i| i.even? ? n * 2 : n * 1 }.reverse
        end

        def sum_of(number)
          split_digits(number).inject(:+)
        end

        def split_digits(number)
          number.to_s.split(//).map(&:to_i)
        end
      end
    end
  end
end
