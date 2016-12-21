# frozen_string_literal: true
# rubocop:disable Style/BlockDelimiters
require 'spec_helper'
require 'rack/mock'

require 'sensitive_data_filter'

describe SensitiveDataFilter do
  it 'has a version number' do
    expect(SensitiveDataFilter::VERSION).not_to be nil
  end

  context 'when configured to handle occurrences' do
    let(:occurrences) { [] }
    let(:occurrence) { occurrences.last }

    before do
      SensitiveDataFilter.config do |config|
        config.on_occurrence { |occurrence| occurrences << occurrence }
      end
    end

    context 'when a request with sensitive data is submitted' do
      let(:status)      { 200 }
      let(:headers)     { {} }
      let(:response)    { 'success' }
      let(:app)         { double }
      let(:middleware)  { SensitiveDataFilter::Middleware::Filter }
      let(:stack)       { middleware.new(app) }
      let(:request)     { Rack::MockRequest.new(stack) }
      let(:base_uri)    { 'https://test.example.com.au/test' }

      before do
        allow(app).to receive(:call).and_return([status, headers, response])
        submit_request
      end

      context 'with POST' do
        let(:input) { '{"credit_card":"4111 1111 1111 1111"}' }
        let(:content_type) { 'application/json' }
        let(:submit_request) {
          request.post(base_uri, input: input, 'CONTENT_TYPE' => content_type)
        }

        specify { expect(occurrences.size).to eq 1 }
        specify { expect(occurrence.filtered_body_params).to eq 'credit_card' => '[FILTERED]' }
        specify { expect(occurrence.matches_count).to eq 'CreditCard' => 1 }
      end

      context 'with GET' do
        let(:uri) { base_uri + '?credit_card=4111111111111111' }
        let(:submit_request) { request.get(uri) }

        specify { expect(occurrences.size).to eq 1 }
        specify { expect(occurrence.filtered_query_params).to eq 'credit_card' => '[FILTERED]' }
        specify { expect(occurrence.matches_count).to eq 'CreditCard' => 1 }
        specify { expect(occurrence.url).to eq base_uri + '?credit_card=%5BFILTERED%5D' }
      end
    end
  end
end
