# frozen_string_literal: true
# rubocop:disable Style/BlockDelimiters
require 'spec_helper'

require 'sensitive_data_filter/scan'

describe SensitiveDataFilter::Scan do
  let(:enabled_types) { [SensitiveDataFilter::Types::CreditCard] }

  let(:credit_card_scanner) { double name: 'CreditCard', scan: matches }

  before do
    stub_const 'SensitiveDataFilter::Types::CreditCard', credit_card_scanner
    allow(SensitiveDataFilter).to receive(:enabled_types).and_return enabled_types
  end

  let(:scan) { SensitiveDataFilter::Scan.new(value) }

  context 'when there are matches' do
    let(:value) { 'Credit card 4111 1111 1111 1111' }
    let(:matches) { ['4111 1111 1111 1111'] }
    specify { expect(scan.matches?).to be true }
    specify { expect(scan.matches).to eq 'CreditCard' => matches }

    context 'when there are no enabled types' do
      let(:enabled_types) { [] }
      specify { expect(scan.matches?).to be false }
      specify { expect(scan.matches).to be_empty }
    end
  end

  context 'when there are no matches' do
    let(:value) { 'Credit card 5111 1111 1111 1111' }
    let(:matches) { [] }
    specify { expect(scan.matches?).to be false }
    specify { expect(scan.matches).to eq 'CreditCard' => matches }
  end
end
