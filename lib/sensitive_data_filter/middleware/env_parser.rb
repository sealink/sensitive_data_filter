# frozen_string_literal: true
require 'forwardable'

module SensitiveDataFilter
  module Middleware
    class EnvParser
      QUERY_STRING = 'QUERY_STRING'.freeze
      RACK_INPUT   = 'rack.input'.freeze

      extend Forwardable

      attr_reader :env

      def initialize(env)
        @env = env
        @request = Rack::Request.new(@env)
        @parameter_parser = ParameterParser.parser_for(@request.media_type)
      end

      def query_params
        Rack::Utils.parse_query(@request.query_string)
      end

      def body_params
        return {} if file_upload?
        body = @request.body.read
        @request.body.rewind
        @parameter_parser.parse(body)
      end

      def query_params=(new_params)
        @env[QUERY_STRING] = Rack::Utils.build_query(new_params)
      end

      def body_params=(new_params)
        @env[RACK_INPUT] = StringIO.new @parameter_parser.unparse(new_params)
      end

      def mutate(mutation)
        SensitiveDataFilter::Middleware::FILTERABLE.each do |filterable|
          self.send("#{filterable}=", mutation.send(filterable))
        end
      end

      def_delegators :@request, :ip, :request_method, :url, :content_type, :session

      private

      def file_upload?
        @request.media_type == 'multipart/form-data'
      end
    end
  end
end
