# frozen_string_literal: true
require 'facets/hash/collate'

module SensitiveDataFilter
  module Middleware
    class ParameterScanner
      def initialize(env_parser)
        @env_parser      = env_parser
        @original_params = @env_parser.query_params.values + @env_parser.body_params.values
      end

      def matches
        scans.map(&:matches).inject(:collate)
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
