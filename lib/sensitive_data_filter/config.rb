# frozen_string_literal: true
require 'facets/string/modulize'

module SensitiveDataFilter
  def self.config
    yield @config = Config.new if block_given?
    @config ||= Config.new
  end

  def self.enabled_types
    config.enabled_types
  end

  def self.handle_occurrence(occurrence)
    handler = config.occurrence_handler
    handler.call(occurrence) if handler
  end

  class Config
    DEFAULT_TYPES = %i(credit_card).freeze

    attr_reader :occurrence_handler

    def enable_types(*types)
      @enabled_types = types.map { |type| SensitiveDataFilter::Types.const_get type.to_s.modulize }
    end

    def enabled_types
      @enabled_types || enable_types(*DEFAULT_TYPES)
    end

    def on_occurrence(&block)
      @occurrence_handler = block
    end
  end
end
