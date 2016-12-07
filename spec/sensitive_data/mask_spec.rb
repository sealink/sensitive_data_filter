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
  end

  describe '#mask_hash' do
    let(:hash) { { a: nil, b: 42, c: 'unmasked' } }
    let(:original_hash) { hash.dup }
    let(:expected_result) { { a: nil, b: 42, c: masked_value } }
    let(:result) { SensitiveDataFilter::Mask.mask_hash hash }

    before do
      original_hash
      result
    end

    specify { expect(result).to eq expected_result }
    specify { expect(hash).to eq original_hash }
  end
end
