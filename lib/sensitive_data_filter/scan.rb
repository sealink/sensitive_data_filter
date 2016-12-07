# frozen_string_literal: true
require 'facets/kernel/present'

module SensitiveDataFilter
  class Scan
    def initialize(value)
      @value = value
    end

    def matches
      @matches ||= SensitiveDataFilter.enabled_types.map.with_object({}) { |scanner, matches|
        matches[scanner.name.split('::').last] = scanner.scan @value
      }
    end

    def matches?
      matches.values.any?(&:present?)
    end
  end
end
