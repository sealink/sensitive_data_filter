# frozen_string_literal: true
require 'facets/kernel/present'

module SensitiveDataFilter
  module Middleware
    class EnvFilter
      attr_reader :occurrence

      def initialize(env)
        @env = env
        @dirty_env_parser = EnvParser.new(env)
        @scanner = ParameterScanner.new(@dirty_env_parser)
        @clean_env_parser = @dirty_env_parser.copy
        @clean_env_parser.mask! if @scanner.sensitive_data?
        @occurrence = build_occurrence
      end

      def clean_env
        @clean_env_parser.env
      end

      def occurrence?
        occurrence.present?
      end

      private

      def build_occurrence
        if @scanner.sensitive_data?
          Occurrence.new(@dirty_env_parser, @clean_env_parser, @scanner.matches)
        end
      end
    end
  end
end
