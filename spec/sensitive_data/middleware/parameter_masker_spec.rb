# frozen_string_literal: true
# rubocop:disable Style/BlockDelimiters
require 'spec_helper'

require 'sensitive_data_filter/middleware/parameter_masker'

describe SensitiveDataFilter::Middleware::ParameterMasker do
  let(:query_params) { { id: 42 } }
  let(:body_params) { { credit_card: '4111 1111 1111 1111' } }
  let(:env_parser) { double query_params: query_params, body_params: body_params }
  subject(:parameter_masker) { SensitiveDataFilter::Middleware::ParameterMasker.new env_parser }

  describe '#mask!' do
    let(:mask) { double }
    let(:filtered_body_params) { { credit_card: '[FILTERED]' } }

    before do
      stub_const 'SensitiveDataFilter::Mask', mask
      allow(mask).to receive(:mask_hash).with(query_params).and_return query_params
      allow(mask).to receive(:mask_hash).with(body_params).and_return filtered_body_params

      allow(env_parser).to receive(:query_params=)
      allow(env_parser).to receive(:body_params=)

      parameter_masker.mask!
    end

    specify { expect(env_parser).to have_received(:query_params=).with query_params }
    specify { expect(env_parser).to have_received(:body_params=).with filtered_body_params }
  end
end
