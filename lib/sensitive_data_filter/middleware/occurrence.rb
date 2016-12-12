# frozen_string_literal: true
require 'facets/string/titlecase'

module SensitiveDataFilter
  module Middleware
    class Occurrence
      extend Forwardable

      attr_reader :matches

      def initialize(original_env_parser, filtered_env_parser, matches)
        @original_env_parser = original_env_parser
        @filtered_env_parser = filtered_env_parser
        @matches             = matches
      end

      def origin_ip
        @original_env_parser.ip
      end

      def original_query_params
        @original_env_parser.query_params
      end

      def original_body_params
        @original_env_parser.body_params
      end

      def filtered_query_params
        @filtered_env_parser.query_params
      end

      def filtered_body_params
        @filtered_env_parser.body_params
      end

      def_delegators :@original_env_parser, :request_method, :url, :session

      def matches_count
        @matches.map { |type, matches| [type, matches.count] }.to_h
      end

      def to_h
        {
          origin_ip:             origin_ip,
          request_method:        request_method,
          url:                   url,
          filtered_query_params: filtered_query_params,
          filtered_body_params:  filtered_body_params,
          session:               session,
          matches_count:         matches_count
        }
      end

      def to_s
        "[SensitiveDataFilter] Sensitive Data detected and masked:\n" +
          to_h.map { |attribute, value| "#{attribute.to_s.titlecase}: #{value}" }.join("\n")
      end
    end
  end
end
