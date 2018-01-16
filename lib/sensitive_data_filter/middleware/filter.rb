# frozen_string_literal: true
module SensitiveDataFilter
  module Middleware
    class Filter
      def initialize(app)
        @app = app
      end

      def call(env)
        original_env = EnvParser.new(env)
        changeset, scan = Detect.new(original_env).call
        unless changeset.nil?
          handle_occurrence(original_env, changeset, scan)
          original_env.mutate(changeset)
        end
        @app.call(env)
      end

      private

      def handle_occurrence(filter, changeset, scan)
        occurence = Occurrence.new(filter, changeset, scan.matches)
        SensitiveDataFilter.handle_occurrence(occurence)
      end
    end
  end
end
