# frozen_string_literal: true
require 'facets/kernel/present'
require 'facets/hash/collate'

module SensitiveDataFilter
  class Scan
    def self.scan(value)
      return scan_array(value) if value.is_a? Array
      return scan_hash(value) if value.is_a? Hash
      SensitiveDataFilter.enabled_types.map.with_object({}) { |scanner, matches|
        matches[scanner.name.split('::').last] = whitelist(scanner.scan(value))
      }
    end

    def self.scan_array(array)
      array.map { |element| scan(element) }.inject(:collate) || {}
    end

    def self.scan_hash(hash)
      hash.map { |key, value| scan(key).collate(scan(value)) }.inject(:collate) || {}
    end

    def self.whitelist(matches)
      matches.reject { |match| SensitiveDataFilter.whitelisted? match }
    end

    def initialize(value)
      @value = value
    end

    def matches
      @matches ||= self.class.scan(@value)
    end

    def matches?
      matches.values.any?(&:present?)
    end
  end
end
