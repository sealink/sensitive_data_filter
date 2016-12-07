# frozen_string_literal: true
module SensitiveDataFilter
  module Middleware
    class ParameterScanner
      def initialize(env_parser)
        @env_parser      = env_parser
        @original_params = @env_parser.query_params.values + @env_parser.body_params.values
      end

      # TODO: Use facets/hash/collate
      def matches
        matches = scans.map(&:matches)
        matches.flat_map(&:keys).uniq.map.with_object({}) { |type, combined_matches|
          combined_matches[type] = matches.map { |type_matches|
            type_matches.fetch(type, [])
          }.inject(:+)
        }
      end

      def sensitive_data?
        scans.any?(&:matches?)
      end

      private

      def scans
        @scans ||= @original_params.map { |value| SensitiveDataFilter::Scan.new(value) }
      end
    end
  end
end
