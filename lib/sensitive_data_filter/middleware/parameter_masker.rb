# frozen_string_literal: true
module SensitiveDataFilter
  module Middleware
    class ParameterMasker
      def initialize(env_parser)
        @env_parser = env_parser
      end

      def mask!
        @env_parser.query_params = SensitiveDataFilter::Mask.mask_hash @env_parser.query_params
        @env_parser.body_params  = SensitiveDataFilter::Mask.mask_hash @env_parser.body_params
      end
    end
  end
end
