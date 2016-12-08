# frozen_string_literal: true
module SensitiveDataFilter
  module Middleware
    class Filter
      def initialize(app)
        @app = app
      end

      def call(env)
        env_filter = EnvFilter.new env
        handle_occurrence env_filter
        @app.call env_filter.clean_env
      end

      private

      def handle_occurrence(env_filter)
        return unless env_filter.occurrence?
        SensitiveDataFilter.handle_occurrence env_filter.occurrence
      end
    end
  end
end
