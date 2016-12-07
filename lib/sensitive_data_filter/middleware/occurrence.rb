# frozen_string_literal: true

module SensitiveDataFilter
  module Middleware
    class Occurrence
      extend Forwardable

      attr_reader :matches

      def initialize(env_parser, matches)
        @env_parser = env_parser
        @matches    = matches
      end

      def origin_ip
        @env_parser.ip
      end

      def filtered_params
        @env_parser.params
      end

      def_delegators :@env_parser, :request_method, :url, :session

      def matches_count
        @matches.map { |type, matches| [type, matches.count] }.to_h
      end

      def to_h
        {
          origin_ip:       origin_ip,
          request_method:  request_method,
          url:             url,
          filtered_params: filtered_params,
          session:         session,
          matches_count:   matches_count
        }
      end

      def to_s
        "[SensitiveDataFilter] Sensitive Data detected and masked:\n" +
          to_h.to_s
      end
    end
  end
end
