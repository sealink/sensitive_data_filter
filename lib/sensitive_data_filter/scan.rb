# frozen_string_literal: true
require 'facets/kernel/present'

module SensitiveDataFilter
  class Scan
    def initialize(value)
      @value = value
    end

    def matches
      @matches ||= SensitiveDataFilter.enabled_types.map.with_object({}) { |scanner, matches|
        matches[scanner.name.split('::').last] = whitelist scanner.scan(@value)
      }
    end

    def matches?
      matches.values.any?(&:present?)
    end

    private

    def whitelist(matches)
      matches.reject { |match| SensitiveDataFilter.whitelisted? match }
    end
  end
end
