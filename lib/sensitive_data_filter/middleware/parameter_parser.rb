# frozen_string_literal: true

module SensitiveDataFilter
  module Middleware
    class ParameterParser
      def self.register_parser(content_type, parse, unparse)
        parsers.unshift new(content_type, parse, unparse)
      end

      def self.parsers
        @parsers ||= DEFAULT_PARSERS.dup
      end

      def self.parser_for(content_type)
        parsers.find { |parser| parser.can_parse? content_type } || NULL_PARSER
      end

      def initialize(content_type, parse, unparse)
        @content_type = content_type
        @parse        = parse
        @unparse      = unparse
      end

      def can_parse?(content_type)
        content_type.to_s.match @content_type
      end

      def parse(params)
        @parse.call params
      rescue
        params
      end

      def unparse(params)
        @unparse.call params
      rescue
        params
      end

      NULL_PARSER = new('', ->(params) { params }, ->(params) { params })

      DEFAULT_PARSERS = [
        new('urlencoded', # e.g.: 'application/x-www-form-urlencoded'
            ->(params) { Rack::Utils.parse_query(params) },
            ->(params) { Rack::Utils.build_query(params) }),
        new('json', # e.g.: 'application/json'
            ->(params) { JSON.parse(params) },
            ->(params) { JSON.unparse(params) })
      ].freeze
    end
  end
end
