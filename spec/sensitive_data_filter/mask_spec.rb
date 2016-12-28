# frozen_string_literal: true
# rubocop:disable Style/BlockDelimiters
require 'spec_helper'

require 'sensitive_data_filter/mask'

describe SensitiveDataFilter::Mask do
  let(:enabled_types) { [SensitiveDataFilter::Types::CreditCard] }

  let(:masked_value) { '[FILTERED]' }
  let(:credit_card_masker) { double mask: masked_value }

  before do
    stub_const 'SensitiveDataFilter::Types::CreditCard', credit_card_masker
    allow(credit_card_masker).to receive(:mask) { |value|
      value.is_a?(String) ? masked_value : value
    }

    allow(SensitiveDataFilter).to receive(:enabled_types).and_return enabled_types
    allow(SensitiveDataFilter).to receive(:whitelisted_key?) { |key| key.match(/phone|mobile/) }
  end

  describe '#mask' do
    let(:result) { SensitiveDataFilter::Mask.mask value }

    context 'with nil' do
      let(:value) { nil }
      specify { expect(result).to eq nil }
    end

    context 'with a number' do
      let(:value) { 42 }
      specify { expect(result).to eq 42 }
    end

    context 'with a string' do
      let(:value) { 'unmasked' }
      specify { expect(result).to eq masked_value }

      context 'when there are no enabled types' do
        let(:enabled_types) { [] }
        specify { expect(result).to eq value }
      end
    end

    context 'with complex values' do
      before do
        original_value
        result
      end

      context 'with a hash' do
        let(:value) {
          { a: nil, b: 42, c: 'unmasked', 'maskable' => 'unmasked', d: [3, 'maskable'] }
        }
        let(:original_value) { value.dup }
        let(:expected_result) {
          { a: nil, b: 42, c: masked_value, masked_value => masked_value, d: [3, masked_value] }
        }

        specify { expect(result).to eq expected_result }
        specify { expect(value).to eq original_value }

        context 'when keys are whitelisted' do
          let(:value) {
            { credit_card: 'maskable', phone: 'maskable' }
          }

          let(:expected_result) {
            { credit_card: masked_value, phone: 'maskable' }
          }

          specify { expect(result).to eq expected_result }
        end
      end

      context 'with an array' do
        let(:value) { [nil, 42, 'unmasked', { 'maskable' => 'unmasked' }] }
        let(:original_value) { value.dup }
        let(:expected_result) { [nil, 42, masked_value, { masked_value => masked_value }] }

        specify { expect(result).to eq expected_result }
        specify { expect(value).to eq original_value }
      end
    end
  end
end
