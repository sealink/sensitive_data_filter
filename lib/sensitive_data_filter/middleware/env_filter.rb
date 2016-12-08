# frozen_string_literal: true
require 'facets/kernel/present'

module SensitiveDataFilter
  module Middleware
    class EnvFilter
      attr_reader :occurrence

      def initialize(env)
        @original_env_parser = EnvParser.new(env)
        @filtered_env_parser = @original_env_parser.copy
        @scanner             = ParameterScanner.new(@original_env_parser)
        @filtered_env_parser.mask! if @scanner.sensitive_data?
        @occurrence = build_occurrence
      end

      def filtered_env
        @filtered_env_parser.env
      end

      def occurrence?
        @occurrence.present?
      end

      private

      def build_occurrence
        return nil unless @scanner.sensitive_data?
        Occurrence.new(@original_env_parser, @filtered_env_parser, @scanner.matches)
      end
    end
  end
end
