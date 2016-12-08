# frozen_string_literal: true
# rubocop:disable Style/BlockDelimiters
require 'spec_helper'

require 'rack/mock'

require 'sensitive_data_filter/middleware/env_parser'

describe SensitiveDataFilter::Middleware::EnvParser do
  let(:env) { Rack::MockRequest.env_for(uri, method: method, input: input) }
  subject(:env_parser) { SensitiveDataFilter::Middleware::EnvParser.new(env) }

  let(:base_uri) { 'https://test.example.com.au/test' }

  specify { expect(env_parser.env).to eq env }

  context 'with a GET request' do
    let(:uri)    { base_uri + '?id=42' }
    let(:method) { 'GET' }
    let(:input)  { nil }

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
    let(:input)  { 'test=42' }

    specify { expect(env_parser.query_params).to be_empty }
    specify { expect(env_parser.body_params).to eq 'test' => '42' }

    describe '#body_params=' do
      let(:rack_input) { env['rack.input'].read.tap { env['rack.input'].rewind } }

      before do
        env_parser.body_params = { test: 1 }
      end

      specify { expect(rack_input).to eq 'test=1' }
      specify { expect(env_parser.body_params).to eq 'test' => '1' }
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

  describe '#params' do
    specify { expect(env_parser.params).to eq 'id' => '42' }
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
    specify { expect(env_parser.body_params).to eq 'test' => '1' }

    specify { expect(masked_env_parser.query_params).to eq 'id' => '2' }
    specify { expect(masked_env_parser.body_params).to eq 'test' => '2' }
  end

  describe '#mask!' do
    let(:uri)    { base_uri + '?id=42&credit_card=4111%201111%201111%201111' }
    let(:method) { 'POST' }
    let(:input)  { 'credit_card=4111 1111 1111 1111' }

    let(:clean_query_params) { { 'id' => '42', 'credit_card' => '[FILTERED]' } }
    let(:clean_body_params)  { { 'credit_card' => '[FILTERED]' } }

    before do
      env_parser.mask!
    end

    specify { expect(env_parser.query_params).to eq clean_query_params }
    specify { expect(env_parser.body_params).to eq clean_body_params }
  end
end
