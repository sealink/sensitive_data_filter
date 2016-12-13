# frozen_string_literal: true
# rubocop:disable Style/BlockDelimiters
require 'spec_helper'

require 'sensitive_data_filter/middleware/occurrence'

describe SensitiveDataFilter::Middleware::Occurrence do
  let(:ip) { '127.0.0.1' }
  let(:request_method) { 'POST' }
  let(:url) { 'https://test.example.com.au/test' }
  let(:content_type) { 'application/json' }
  let(:original_query_params) { { 'credit_card' => '4111 1111 1111 1111' } }
  let(:filtered_query_params) { { 'credit_card' => '[FILTERED]' } }
  let(:original_body_params) { { credit_cards: '4111 1111 1111 1111 and 5123 4567 8901 2346' } }
  let(:filtered_body_params) { { credit_cards: '[FILTERED] and [FILTERED]' } }
  let(:session) { { 'session_id' => '01ab02cd' } }
  let(:original_env_parser) {
    double(
      ip:             ip,
      request_method: request_method,
      url:            url,
      content_type:   content_type,
      query_params:   original_query_params,
      body_params:    original_body_params,
      session:        session
    )
  }
  let(:filtered_env_parser) {
    double(
      ip:             ip,
      request_method: request_method,
      url:            url,
      content_type:   content_type,
      query_params:   filtered_query_params,
      body_params:    filtered_body_params,
      session:        session
    )
  }
  let(:matches) {
    {
      'CreditCard' => ['4111 1111 1111 1111', '5123456789012346']
    }
  }
  let(:matches_count) { { 'CreditCard' => 2 } }
  subject(:occurrence) {
    SensitiveDataFilter::Middleware::Occurrence.new(
      original_env_parser,
      filtered_env_parser,
      matches
    )
  }

  specify { expect(occurrence.matches).to eq matches }
  specify { expect(occurrence.origin_ip).to eq ip }
  specify { expect(occurrence.request_method).to eq request_method }
  specify { expect(occurrence.url).to eq url }
  specify { expect(occurrence.original_query_params).to eq original_query_params }
  specify { expect(occurrence.original_body_params).to eq original_body_params }
  specify { expect(occurrence.filtered_query_params).to eq filtered_query_params }
  specify { expect(occurrence.filtered_body_params).to eq filtered_body_params }
  specify { expect(occurrence.session).to eq session }
  specify { expect(occurrence.matches_count).to eq matches_count }

  let(:expected_to_h) {
    {
      origin_ip:             ip,
      request_method:        request_method,
      url:                   url,
      content_type:          content_type,
      filtered_query_params: filtered_query_params,
      filtered_body_params:  filtered_body_params,
      session:               session,
      matches_count:         matches_count
    }
  }

  let(:expected_to_s) {
    "[SensitiveDataFilter] Sensitive Data detected and masked:\n"\
    "Origin Ip: 127.0.0.1\n"\
    "Request Method: POST\n"\
    "Url: https://test.example.com.au/test\n"\
    "Content Type: application/json\n"\
    "Filtered Query Params: {\"credit_card\"=>\"[FILTERED]\"}\n"\
    "Filtered Body Params: {:credit_cards=>\"[FILTERED] and [FILTERED]\"}\n"\
    "Session: {\"session_id\"=>\"01ab02cd\"}\n"\
    'Matches Count: {"CreditCard"=>2}'
  }

  specify { expect(occurrence.to_h).to eq expected_to_h }
  specify { expect(occurrence.to_s).to eq expected_to_s }
end
