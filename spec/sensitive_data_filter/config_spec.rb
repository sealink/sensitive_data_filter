# frozen_string_literal: true
# rubocop:disable Style/BlockDelimiters
require 'spec_helper'

require 'sensitive_data_filter/config'

describe SensitiveDataFilter do
  let(:credit_card_type) { double 'CreditCard' }

  before do
    stub_const 'SensitiveDataFilter::Types::CreditCard', credit_card_type
  end

  describe '#enabled_types' do
    context 'when not configured' do
      specify { expect(SensitiveDataFilter.enabled_types).to eq [credit_card_type] }
    end

    context 'when configured' do
      let(:test_type) { double 'TestType' }

      before do
        stub_const 'SensitiveDataFilter::Types::TestType', test_type

        SensitiveDataFilter.config do |config|
          config.enable_types :test_type
        end
      end

      specify { expect(SensitiveDataFilter.enabled_types).to eq [test_type] }
    end
  end

  describe '#handle_occurrence' do
    let(:occurrence) { double }

    context 'when not configured' do
      specify { expect(SensitiveDataFilter.handle_occurrence(occurrence)).to be_nil }
    end

    context 'when configured' do
      let(:handler) { double }

      before do
        allow(handler).to receive(:handle).with occurrence
        SensitiveDataFilter.config do |config|
          config.on_occurrence { |occurrence| handler.handle occurrence }
        end
        SensitiveDataFilter.handle_occurrence occurrence
      end

      specify { expect(handler).to have_received(:handle).with occurrence }
    end
  end

  describe '#whitelisted?' do
    before do
      SensitiveDataFilter.config do |config|
        config.whitelist 'is allowed', 'is acceptable'
      end
    end

    let(:allowed_value) { 'this is allowed' }
    let(:non_allowed_value) { 'this is not allowed' }

    specify { expect(SensitiveDataFilter.whitelisted?(allowed_value)).to be true }
    specify { expect(SensitiveDataFilter.whitelisted?(non_allowed_value)).to be false }
  end

  describe '#whitelisted_key?' do
    before do
      SensitiveDataFilter.config do |config|
        config.whitelist_key 'is allowed', 'is acceptable'
      end
    end

    let(:allowed_key) { 'this is allowed' }
    let(:non_allowed_key) { 'this is not allowed' }

    specify { expect(SensitiveDataFilter.whitelisted_key?(allowed_key)).to be true }
    specify { expect(SensitiveDataFilter.whitelisted_key?(non_allowed_key)).to be false }
  end

  describe '#register_parser' do
    let(:parameter_parser) { double }
    let(:parse) { double }
    let(:unparse) { double }

    before do
      stub_const 'SensitiveDataFilter::Middleware::ParameterParser', parameter_parser
      allow(parameter_parser).to receive(:register_parser)

      SensitiveDataFilter.config do |config|
        config.register_parser 'test', parse, unparse
      end
    end

    specify {
      expect(parameter_parser).to have_received(:register_parser).with('test', parse, unparse)
    }
  end
end
