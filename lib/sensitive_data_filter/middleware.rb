# frozen_string_literal: true
module SensitiveDataFilter
  module Middleware
    FILTERABLE = %i(query_params body_params).freeze
  end
end

require 'sensitive_data_filter/middleware/parameter_parser'
require 'sensitive_data_filter/middleware/env_parser'
require 'sensitive_data_filter/middleware/occurrence'
require 'sensitive_data_filter/middleware/detect'
require 'sensitive_data_filter/middleware/filter'
