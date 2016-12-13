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

      let(:uri)          { 'https://test.example.com.au/test' }
      let(:input)        { '{"credit_card":"4111 1111 1111 1111"}' }
      let(:content_type) { 'application/json' }

      before do
        allow(app).to receive(:call).and_return([status, headers, response])
        request.post(uri, input: input, 'CONTENT_TYPE' => content_type)
      end

      specify { expect(occurrences.size).to eq 1 }
      specify { expect(occurrence.filtered_body_params).to eq 'credit_card' => '[FILTERED]' }
      specify { expect(occurrence.matches_count).to eq 'CreditCard' => 1 }
    end
  end
end
