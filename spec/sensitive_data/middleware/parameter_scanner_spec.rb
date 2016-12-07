# frozen_string_literal: true
require 'spec_helper'

require 'sensitive_data_filter/middleware/parameter_scanner'

describe SensitiveDataFilter::Middleware::ParameterScanner do
  let(:query_params) { { id: 42, credit_card: '5123 4567 8901 2346' } }
  let(:body_params) { { credit_card: '4111 1111 1111 1111' } }
  let(:env_parser) { double query_params: query_params, body_params: body_params }
  subject(:parameter_masker) { SensitiveDataFilter::Middleware::ParameterScanner.new env_parser }

  let(:scan_class) { double }
  let(:non_matching_scan) {
    double matches?: false, matches: { 'CreditCard' => [] }
  }
  let(:first_matching_scan) {
    double matches?: true, matches: { 'CreditCard' => ['5123 4567 8901 2346'] }
  }
  let(:second_matching_scan) {
    double matches?: true, matches: { 'CreditCard' => ['4111 1111 1111 1111'] }
  }

  before do
    stub_const 'SensitiveDataFilter::Scan', scan_class
    allow(scan_class).to receive(:new).with(42).and_return non_matching_scan
    allow(scan_class).to receive(:new).with('5123 4567 8901 2346').and_return first_matching_scan
    allow(scan_class).to receive(:new).with('4111 1111 1111 1111').and_return second_matching_scan
  end

  describe '#sensitive_data_filter?' do
    specify { expect(parameter_masker.sensitive_data?).to be true }
  end

  describe '#matches' do
    specify {
      expect(parameter_masker.matches)
        .to eq 'CreditCard' => ['5123 4567 8901 2346', '4111 1111 1111 1111']
    }
  end
end
