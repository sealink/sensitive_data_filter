# frozen_string_literal: true
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

      def copy
        self.class.new(@env.clone)
      end

      def mask!
        self.query_params = SensitiveDataFilter::Mask.mask(query_params)
        self.body_params  = SensitiveDataFilter::Mask.mask(body_params)
      end

      def_delegators :@request, :ip, :request_method, :url, :content_type, :params, :session

      private

      def file_upload?
        @request.media_type == 'multipart/form-data'
      end
    end
  end
end
