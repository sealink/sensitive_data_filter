# frozen_string_literal: true
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
end
