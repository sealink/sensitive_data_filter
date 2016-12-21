# frozen_string_literal: true
# rubocop:disable Style/BlockDelimiters
require 'spec_helper'

require 'sensitive_data_filter/middleware/env_filter'

describe SensitiveDataFilter::Middleware::EnvFilter do
  let(:env_parser_class) { double }
  let(:env_parser)       {
    double 'original_env_parser', query_params: query_params, body_params: body_params
  }
  let(:query_params) { double }
  let(:body_params)  { double }
  let(:env_parser_copy)  { double 'filtered_env_parser', env: filtered_env }
  let(:filtered_env)     { double 'filtered_env' }

  let(:scan_class) { double }
  let(:scan)       { double matches?: matches?, matches: scan_matches }
  let(:scan_matches) { double }

  let(:parameter_masker_class) { double }
  let(:parameter_masker)       { double }

  let(:occurrence_class) { double }
  let(:occurrence)       { double }

  let(:env)         { double }
  let(:env_filter)  { SensitiveDataFilter::Middleware::EnvFilter.new(env) }

  before do
    stub_const 'SensitiveDataFilter::Middleware::EnvParser', env_parser_class
    allow(env_parser_class).to receive(:new).with(env).and_return env_parser
    allow(env_parser).to receive(:copy).and_return env_parser_copy

    allow(env_parser_copy).to receive(:mask!)

    stub_const 'SensitiveDataFilter::Scan', scan_class
    allow(scan_class)
      .to receive(:new).with([env_parser.query_params, env_parser.body_params]).and_return scan

    stub_const 'SensitiveDataFilter::Middleware::Occurrence', occurrence_class
    allow(occurrence_class)
      .to receive(:new).with(env_parser, env_parser_copy, scan_matches).and_return occurrence

    env_filter
  end

  context 'when sensitive data is detected' do
    let(:matches?) { true }
    specify { expect(env_parser_copy).to have_received :mask! }
    specify { expect(env_filter.occurrence?).to be true }
    specify { expect(env_filter.occurrence).to eq occurrence }
    specify { expect(env_filter.filtered_env).to eq filtered_env }
  end

  context 'when sensitive data is not detected' do
    let(:matches?) { false }
    specify { expect(env_parser_copy).not_to have_received :mask! }
    specify { expect(env_filter.occurrence?).to be false }
    specify { expect(env_filter.occurrence).to be_nil }
    specify { expect(env_filter.filtered_env).to eq filtered_env }
  end
end