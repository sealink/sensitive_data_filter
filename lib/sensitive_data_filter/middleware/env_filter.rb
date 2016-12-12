# frozen_string_literal: true
require 'facets/kernel/present'

module SensitiveDataFilter
  module Middleware
    class EnvFilter
      attr_reader :occurrence

      def initialize(env)
        @original_env_parser = EnvParser.new(env)
        @filtered_env_parser = @original_env_parser.copy
        @scan = build_scan
        @filtered_env_parser.mask! if @scan.matches?
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
        return nil unless @scan.matches?
        Occurrence.new(@original_env_parser, @filtered_env_parser, @scan.matches)
      end

      def build_scan
        SensitiveDataFilter::Scan.new(
          [@original_env_parser.query_params, @original_env_parser.body_params]
        )
      end
    end
  end
end
