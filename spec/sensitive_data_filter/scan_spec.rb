# frozen_string_literal: true
# rubocop:disable Style/BlockDelimiters
require 'spec_helper'

require 'sensitive_data_filter/scan'

describe SensitiveDataFilter::Scan do
  let(:credit_card_scanner) { double name: 'CreditCard' }
  let(:enabled_types) { [credit_card_scanner] }
  let(:whitelisted?)  { false }
  let(:credit_card) { '4111 1111 1111 1111' }

  before do
    allow(SensitiveDataFilter).to receive(:enabled_types).and_return enabled_types
    allow(credit_card_scanner).to receive(:scan) { |value| value.to_s.scan credit_card }
    allow(SensitiveDataFilter).to receive(:whitelisted?).and_return whitelisted?
  end

  let(:scan) { SensitiveDataFilter::Scan.new(value) }

  context 'when there are matches' do
    let(:value) { 'Credit card 4111 1111 1111 1111' }
    let(:matches) { ['4111 1111 1111 1111'] }

    context 'after scanning' do
      before do
        scan.matches?
      end
      specify { expect(credit_card_scanner).to have_received(:scan).with(value) }
    end

    specify { expect(scan.matches?).to be true }
    specify { expect(scan.matches).to eq 'CreditCard' => matches }

    context 'when there are no enabled types' do
      let(:enabled_types) { [] }
      specify { expect(scan.matches?).to be false }
      specify { expect(scan.matches).to be_empty }
    end

    context 'when the matches are whitelisted' do
      let(:whitelisted?) { true }
      specify { expect(scan.matches?).to be false }
      specify { expect(scan.matches).to eq 'CreditCard' => [] }
    end
  end

  context 'when there are no matches' do
    let(:value) { 'Credit card 5111 1111 1111 1111' }
    let(:matches) { [] }
    specify { expect(scan.matches?).to be false }
    specify { expect(scan.matches).to eq 'CreditCard' => matches }
  end

  context 'with complex values' do
    let(:credit_card) { '4111 1111 1111 1111' }
    let(:matchable_value) { 'Credit card ' + credit_card }
    let(:matches) { [credit_card] }
    let(:value) {
      {
        a: nil,
        b: 42,
        c: matchable_value,
        d: [3, matchable_value],
        e: [nil, {}, { 'credit card' => matchable_value }],
        matchable_value => matchable_value
      }
    }

    context 'after scanning' do
      before do
        scan.matches?
      end
      specify {
        expect(credit_card_scanner).to have_received(:scan).with('credit card').exactly(1).times
      }
      specify {
        expect(credit_card_scanner).to have_received(:scan).with(matchable_value).exactly(5).times
      }
    end

    specify { expect(scan.matches?).to be true }
    specify { expect(scan.matches).to eq 'CreditCard' => [credit_card] * 5 }
  end
end
