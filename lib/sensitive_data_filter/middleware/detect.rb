module SensitiveDataFilter
  module Middleware
    class Detect
      def initialize(filter)
        @filter = filter
      end

      def call
        changeset = nil
        scan = run_scan
        if scan.matches?
          changeset = OpenStruct.new(SensitiveDataFilter::Middleware::FILTERABLE.each_with_object({}) { |filterable, hash|
            hash[filterable.to_s] = SensitiveDataFilter::Mask.mask(@filter.send(filterable))
          })
        end
        [changeset, scan]
      end

      private

      def run_scan
        SensitiveDataFilter::Scan.new(
          SensitiveDataFilter::Middleware::FILTERABLE.map { |filterable| @filter.send(filterable) }
        )
      end
    end
  end
end
