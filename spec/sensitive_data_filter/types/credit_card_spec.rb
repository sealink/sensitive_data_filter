# frozen_string_literal: true
# rubocop:disable Style/BlockDelimiters
require 'spec_helper'
require 'sensitive_data_filter/types/credit_card'

describe SensitiveDataFilter::Types::CreditCard do
  describe '#valid?' do
    let(:example_cards) {
      {
        'American Express'           => ['3782 822463 10005', '3714 496353 98431'],
        'American Express Corporate' => ['3787 344936 71000'],
        'Australian BankCard'        => ['5610 5910 8101 8250'],
        'Diners Club'                => ['3056 930902 5904', '3852 000002 3237'],
        'Discover'                   => ['6011 1111 1111 1117', '6011 0009 9013 9424'],
        'JCB'                        => ['3530 1113 3330 0000', '3566 0020 2036 0505'],
        'MasterCard'                 => ['5555 5555 5555 4444', '5105 1051 0510 5100'],
        'Visa'                       => ['4111 1111 1111 1111', '4012 8888 8888 1881',
                                         '422 222 222 2 222'],
        'Dankort (PBS)'              => ['5019 7170 1010 3742'],
        'Switch/Solo (Paymentech)'   => ['6331 1019 9999 0016'],
        'Unconventionally Typed'     => ['3782  8224  6310  005', '4111111111111111']
      }
    }
    let(:valid_cards) { example_cards.values.flatten }
    let(:invalid_cards) { ['1111 1111 1111 1111', '1234 567890 12345', '123 456 789 0 123'] }

    def replace_separator(cards, separator)
      cards.map { |card| card.gsub(' ', separator) }
    end

    def validations(cards)
      cards.map { |card| SensitiveDataFilter::Types::CreditCard.valid? card }
    end

    separators = ['', ' ', '-']
    separators.repeated_permutation(2).map(&:join).uniq.each do |separator|
      context "with separator #{separator}" do
        specify { expect(validations(replace_separator(valid_cards, separator))).to all be true }
        specify { expect(validations(replace_separator(invalid_cards, separator))).to all be false }
      end
    end
  end

  describe '#scan and #mask' do
    let(:scan) { SensitiveDataFilter::Types::CreditCard.scan value }
    let(:mask) { SensitiveDataFilter::Types::CreditCard.mask value }

    context 'a value that contains valid credit card numbers' do
      let(:value) {
        'This text contains 5123 4567 8901 2346 and 4111 1111 1111 1111, '\
        'which are valid credit card numbers, '\
        'and 4123 4567 8912 3456, which is not a valid credit card number.'
      }
      specify { expect(scan).to eq ['5123 4567 8901 2346', '4111 1111 1111 1111'] }

      let(:masked_value) {
        'This text contains [FILTERED] and [FILTERED], '\
        'which are valid credit card numbers, '\
        'and 4123 4567 8912 3456, which is not a valid credit card number.'
      }
      specify { expect(mask).to eq masked_value }
    end

    context 'a value that contains valid credit card numbers in a longer numerical pattern' do
      let(:value) { '1234111111111111111234' }
      specify { expect(scan).to be_empty }
    end

    context 'a value that contains valid credit card numbers preceded by numbers' do
      let(:value) { '1234111111111111111' }
      specify { expect(scan).to be_empty }
    end

    context 'a value that contains valid credit card numbers followed by numbers' do
      let(:value) { '4111111111111111321' }
      specify { expect(scan).to be_empty }
    end

    context 'a value that contains a valid credit card number separated from other numbers' do
      let(:value) { '123 4111 1111 1111 1111 234' }
      specify { expect(scan).to eq ['4111 1111 1111 1111'] }
    end

    context 'a value that contains valid credit card numbers between letters' do
      let(:value) { 'abc4111111111111111dfg' }
      specify { expect(scan).to be_empty }
    end

    context 'a value that contains valid credit card numbers preceded by letters' do
      let(:value) { 'abc4111111111111111' }
      specify { expect(scan).to be_empty }
    end

    context 'a value that contains valid credit card numbers followed by letters' do
      let(:value) { '4111111111111111abc' }
      specify { expect(scan).to be_empty }
    end

    context 'a value that contains a valid credit card number separated from other characters' do
      let(:value) { 'abc 4111 1111 1111 1111 dfg' }
      specify { expect(scan).to eq ['4111 1111 1111 1111'] }
    end

    context 'a value that contains repeated valid credit card numbers' do
      let(:value) { 'cc1 4111 1111 1111 1111 cc2 4111 1111 1111 1111 123' }
      specify { expect(scan).to eq ['4111 1111 1111 1111', '4111 1111 1111 1111'] }
    end

    context 'a value that contains a valid credit card in a multi line string' do
      let(:value) { "@TEST\n3782 822463 10005\nEXP: 07/20\n" }
      specify { expect(scan).to eq ['3782 822463 10005'] }
      specify { expect(mask).to eq "@TEST\n[FILTERED]\nEXP: 07/20\n" }
    end

    context 'a value that contains a valid tab separated credit card on multiple lines' do
      let(:value) { "@TEST\n3782\t822463\n10005\nEXP: 07/20\n" }
      specify { expect(scan).to eq ["3782\t822463\n10005"] }
      specify { expect(mask).to eq "@TEST\n[FILTERED]\nEXP: 07/20\n" }
    end

    context 'a value that is a luhn but not a credit card' do
      let(:value) { '1230-2675-9183-4267' }
      specify { expect(scan).to be_empty }
      specify { expect(mask).to eq value }
    end

    context 'a value that does not contain valid credit card numbers' do
      let(:value) { 'This text does not contain credit card values' }
      specify { expect(scan).to be_empty }
      specify { expect(mask).to eq value }
    end

    context 'a value that is not a string' do
      let(:value) { 42 }
      specify { expect(scan).to be_empty }
      specify { expect(mask).to eq value }
    end

    context 'a nil value' do
      let(:value) { nil }
      specify { expect(scan).to be_empty }
      specify { expect(mask).to eq value }
    end
  end
end
