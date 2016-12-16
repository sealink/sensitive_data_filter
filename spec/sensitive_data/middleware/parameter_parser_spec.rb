# frozen_string_literal: true
# rubocop:disable Style/BlockDelimiters
require 'spec_helper'

require 'rack/utils'
require 'sensitive_data_filter/middleware/parameter_parser'

describe SensitiveDataFilter::Middleware::ParameterParser do
  let(:parser_class) { SensitiveDataFilter::Middleware::ParameterParser }
  let(:parser) { parser_class.parser_for content_type }
  let(:null_parser) { SensitiveDataFilter::Middleware::ParameterParser::NULL_PARSER }

  specify { expect(null_parser).not_to be_nil }
  specify { expect(null_parser.parse('test')).to eq 'test' }
  specify { expect(null_parser.unparse('test')).to eq 'test' }

  describe 'default urlencoded parser' do
    let(:content_type) { 'application/x-www-form-urlencoded' }
    let(:parameters) { 'test=true' }

    specify { expect(parser).not_to be null_parser }
    specify { expect(parser.parse(parameters)).to eq 'test' => 'true' }
    specify { expect(parser.unparse('test' => 'true')).to eq parameters }
  end

  describe 'default JSON parser' do
    let(:content_type) { 'application/json' }
    let(:parameters) { '{"test":true}' }

    specify { expect(parser).not_to be null_parser }
    specify { expect(parser.parse(parameters)).to eq 'test' => true }
    specify { expect(parser.unparse('test' => true)).to eq parameters }
  end

  describe 'a custom parser' do
    let(:content_type) { 'application/test' }
    let(:parameters) { 'test|true' }

    let(:parser) { parser_class.parser_for content_type }
    specify { expect(parser).to be null_parser }

    context 'when defined' do
      before do
        parser_class.register_parser(
          'test',
          ->(params) { params.split('|') },
          ->(params) { params.join('|') }
        )
      end

      specify { expect(parser).not_to be null_parser }
      specify { expect(parser.parse(parameters)).to eq %w(test true) }
      specify { expect(parser.unparse(%w(test true))).to eq parameters }

      context 'when redefined' do
        before do
          parser_class.register_parser(
            'test',
            ->(params) { params.tr('|', '&') },
            ->(params) { params.tr('&', '|') }
          )
        end

        specify { expect(parser).not_to be null_parser }
        specify { expect(parser.parse(parameters)).to eq 'test&true' }
        specify { expect(parser.unparse('test&true')).to eq parameters }
      end
    end
  end

  context 'when parsing raises exceptions' do
    let(:content_type) { 'application/test' }

    before do
      parser_class.register_parser(
        'test',
        ->(_params) { fail 'Parsing Error' },
        ->(_params) { fail 'Parsing Error' }
      )
    end

    specify { expect{parser.parse('test')}.not_to raise_error }
    specify { expect(parser.parse('test')).to eq 'test' }
    specify { expect{parser.unparse('test')}.not_to raise_error }
    specify { expect(parser.unparse('test')).to eq 'test' }
  end

  context 'when the content type is nil' do
    let(:content_type) { nil }
    specify { expect(parser).to be null_parser }
  end
end
