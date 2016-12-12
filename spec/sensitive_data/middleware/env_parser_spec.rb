# frozen_string_literal: true
# rubocop:disable Style/BlockDelimiters
require 'spec_helper'

require 'rack/mock'

require 'sensitive_data_filter/middleware/env_parser'

describe SensitiveDataFilter::Middleware::EnvParser do
  let(:env) { Rack::MockRequest.env_for(uri, method: method, input: input) }
  subject(:env_parser) { SensitiveDataFilter::Middleware::EnvParser.new(env) }

  let(:parameter_parser_class) { double }
  let(:null_parameter_parser) { double }
  let(:json_parameter_parser) { double }

  let(:content_type) { 'application/json' }
  let(:parsers) { { 'application/json' => json_parameter_parser } }

  before do
    stub_const 'SensitiveDataFilter::Middleware::ParameterParser', parameter_parser_class
    allow(parameter_parser_class).to receive(:parser_for) { |content_type|
      parsers[content_type] || null_parameter_parser
    }
    env['CONTENT_TYPE'] = content_type

    allow(null_parameter_parser).to receive(:parse) { |params| params }
    allow(null_parameter_parser).to receive(:unparse) { |params| params }

    allow(json_parameter_parser).to receive(:parse) { |params| JSON.parse(params) }
    allow(json_parameter_parser).to receive(:unparse) { |params| JSON.unparse(params) }
  end

  let(:base_uri) { 'https://test.example.com.au/test' }

  specify { expect(env_parser.env).to eq env }

  context 'with a GET request' do
    let(:uri)    { base_uri + '?id=42' }
    let(:method) { 'GET' }
    let(:input)  { nil }
    let(:content_type) { '' }

    specify { expect(env_parser.query_params).to eq 'id' => '42' }
    specify { expect(env_parser.body_params).to be_empty }

    describe '#query_params=' do
      before do
        env_parser.query_params = { id: 1 }
      end

      specify { expect(env['QUERY_STRING']).to eq 'id=1' }
      specify { expect(env_parser.query_params).to eq 'id' => '1' }
    end
  end

  context 'with a POST request' do
    let(:uri)    { base_uri }
    let(:method) { 'POST' }
    let(:input)  { '{"test":42}' }

    specify { expect(env_parser.content_type).to eq content_type }
    specify { expect(env_parser.query_params).to be_empty }
    specify { expect(env_parser.body_params).to eq 'test' => 42 }

    describe '#body_params=' do
      let(:rack_input) { env['rack.input'].read.tap { env['rack.input'].rewind } }

      before do
        env_parser.body_params = { test: 1 }
      end

      specify { expect(rack_input).to eq '{"test":1}' }
      specify { expect(env_parser.body_params).to eq 'test' => 1 }
    end

    context 'when uploading a file' do
      let(:content_type) { 'multipart/form-data' }

      before do
        env_parser.body_params
      end

      specify { expect(null_parameter_parser).not_to have_received(:parse) }
      specify { expect(env_parser.body_params).to be_empty }
    end
  end

  let(:uri)    { base_uri + '?id=42' }
  let(:method) { 'GET' }
  let(:input)  { nil }

  # :ip, :request_method, :url, :params
  describe '#ip' do
    let(:origin_ip) { '127.0.0.1' }
    before do
      env['REMOTE_ADDR'] = origin_ip
    end
    specify { expect(env_parser.ip).to eq origin_ip }
  end

  describe '#request_method' do
    specify { expect(env_parser.request_method).to eq method }
  end

  describe '#url' do
    specify { expect(env_parser.url).to eq uri }
  end

  describe '#session' do
    before do
      env['rack.session'] = { 'session_id' => '01ab02cd' }
    end
    specify { expect(env_parser.session).to eq 'session_id' => '01ab02cd' }
  end

  describe '#copy' do
    let(:masked_env_parser) { env_parser.copy }

    before do
      masked_env_parser.query_params = { id: 2 }
      masked_env_parser.body_params = { test: 2 }

      env_parser.query_params = { id: 1 }
      env_parser.body_params = { test: 1 }
    end

    specify { expect(env_parser.query_params).to eq 'id' => '1' }
    specify { expect(env_parser.body_params).to eq 'test' => 1 }

    specify { expect(masked_env_parser.query_params).to eq 'id' => '2' }
    specify { expect(masked_env_parser.body_params).to eq 'test' => 2 }
  end

  describe '#mask!' do
    let(:query_params) { { 'sensitive_query' => 'sensitive_data' } }
    let(:body_params) { { 'sensitive_body' => 'sensitive_data' } }

    before do
      env_parser.query_params = { sensitive_query: 'sensitive_data' }
      env_parser.body_params  = { sensitive_body: 'sensitive_data' }
    end

    context 'before masking' do
      specify { expect(env_parser.query_params).to eq 'sensitive_query' => 'sensitive_data' }
      specify { expect(env_parser.body_params).to eq 'sensitive_body' => 'sensitive_data' }
    end

    context 'after masking' do
      let(:mask) { double }
      let(:filtered_query_params) { { 'sensitive_query' => '[FILTERED]' } }
      let(:filtered_body_params) { { 'sensitive_body' => '[FILTERED]' } }

      before do
        stub_const 'SensitiveDataFilter::Mask', mask
        allow(mask).to receive(:mask).with(query_params).and_return filtered_query_params
        allow(mask).to receive(:mask).with(body_params).and_return filtered_body_params
        env_parser.mask!
      end

      specify { expect(mask).to have_received(:mask).with query_params }
      specify { expect(mask).to have_received(:mask).with body_params }
      specify { expect(env_parser.query_params).to eq filtered_query_params }
      specify { expect(env_parser.body_params).to eq filtered_body_params }
    end
  end
end
