# frozen_string_literal: true
module SensitiveDataFilter
  module Middleware
    class EnvParser
      extend Forwardable

      attr_reader :env, :request

      def initialize(env)
        @env = env
        @request = Rack::Request.new(@env)
      end

      def query_params
        Rack::Utils.parse_query(request.query_string)
      end

      def body_params
        body = request.body.read
        request.body.rewind
        Rack::Utils.parse_query(body)
      end

      def query_params=(new_params)
        @env['QUERY_STRING'] = Rack::Utils.build_query(new_params)
      end

      def body_params=(new_params)
        @env['rack.input'] = StringIO.new Rack::Utils.build_query(new_params)
      end

      def copy
        copy = self.class.new(@env.clone)
      end

      def mask!
        self.query_params = SensitiveDataFilter::Mask.mask_hash(query_params)
        self.body_params  = SensitiveDataFilter::Mask.mask_hash(body_params)
      end

      def_delegators :request, :ip, :request_method, :url, :params, :session
    end
  end
end
