# frozen_string_literal: true
module SensitiveDataFilter
  module Middleware
    class Filter
      def initialize(app)
        @app = app
      end

      def call(env)
        env_parser = EnvParser.new env
        scanner    = ParameterScanner.new env_parser
        if scanner.sensitive_data?
          ParameterMasker.new(env_parser).mask!
          SensitiveDataFilter.handle_occurrence Occurrence.new(env_parser, scanner.matches)
        end
        @app.call env
      end
    end
  end
end
