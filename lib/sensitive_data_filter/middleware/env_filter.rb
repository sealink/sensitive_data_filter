# frozen_string_literal: true
require 'facets/kernel/present'

module SensitiveDataFilter
  module Middleware
    class EnvFilter
      def initialize(env)
        @env = env
        @original_env_parser = EnvParser.new env
        @filtered_env_parser = @original_env_parser.copy
        @filtered_env_parser.mask! if @scanner.sensitive_data?
      end

      def filtered_env
        @filtered_env_parser.env
      end

      def occurrence?
        occurrence.present?
      end

      def occurrence
        return nil unless scanner.sensitive_data?
        @occurrence ||= Occurrence.new(@original_env_parser, @filtered_env_parser, scanner.matches)
      end

      private

      def scanner
        @scanner ||= ParameterScanner.new @original_env_parser
      end
    end
  end
end
