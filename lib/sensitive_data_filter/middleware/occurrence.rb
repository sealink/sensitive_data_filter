# frozen_string_literal: true
require 'facets/string/titlecase'

module SensitiveDataFilter
  module Middleware
    class Occurrence
      extend Forwardable

      attr_reader :matches

      def initialize(dirty_env_parser, clean_env_parser, matches)
        @dirty_env_parser = dirty_env_parser
        @clean_env_parser = clean_env_parser
        @matches          = matches
      end

      def origin_ip
        @dirty_env_parser.ip
      end

      def dirty_params
        @dirty_env_parser.params
      end

      def clean_params
        @clean_env_parser.params
      end

      def_delegators :@dirty_env_parser, :request_method, :url, :session

      def matches_count
        @matches.map { |type, matches| [type, matches.count] }.to_h
      end

      def to_h
        {
          origin_ip:      origin_ip,
          request_method: request_method,
          url:            url,
          clean_params:   clean_params,
          session:        session,
          matches_count:  matches_count
        }
      end

      def to_s
        "[SensitiveDataFilter] Sensitive Data detected and masked:\n" +
          to_h.map { |attribute, value| "#{attribute.to_s.titlecase}: #{value}" }.join("\n")
      end
    end
  end
end
