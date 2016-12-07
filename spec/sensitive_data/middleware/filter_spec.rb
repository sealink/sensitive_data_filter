# frozen_string_literal: true
# rubocop:disable Style/BlockDelimiters
require 'spec_helper'

require 'sensitive_data_filter/middleware/filter'

describe SensitiveDataFilter::Middleware::Filter do
  let(:env_parser_class) { double }
  let(:env_parser)       { double }

  let(:parameter_scanner_class) { double }
  let(:parameter_scanner)       { double sensitive_data?: sensitive_data?, matches: scan_matches }
  let(:scan_matches)            { double }

  let(:parameter_masker_class) { double }
  let(:parameter_masker)       { double }

  let(:occurrence_class) { double }
  let(:occurrence)       { double }

  let(:app)         { double }
  let(:middleware)  { SensitiveDataFilter::Middleware::Filter }
  let(:stack)       { middleware.new(app) }
  let(:env)         { double }

  before do
    stub_const 'SensitiveDataFilter::Middleware::EnvParser', env_parser_class
    allow(env_parser_class).to receive(:new).with(env).and_return env_parser

    stub_const 'SensitiveDataFilter::Middleware::ParameterScanner', parameter_scanner_class
    allow(parameter_scanner_class).to receive(:new).with(env_parser).and_return parameter_scanner

    stub_const 'SensitiveDataFilter::Middleware::ParameterMasker', parameter_masker_class
    allow(parameter_masker_class).to receive(:new).with(env_parser).and_return parameter_masker
    allow(parameter_masker).to receive(:mask!)

    stub_const 'SensitiveDataFilter::Middleware::Occurrence', occurrence_class
    allow(occurrence_class).to receive(:new).with(env_parser, scan_matches).and_return occurrence
    allow(SensitiveDataFilter).to receive(:handle_occurrence).with occurrence

    allow(app).to receive(:call)

    stack.call(env)
  end

  context 'when sensitive data is detected' do
    let(:sensitive_data?) { true }
    specify {
      expect(parameter_masker).to have_received(:mask!).ordered
      expect(SensitiveDataFilter).to have_received(:handle_occurrence).with occurrence
    }
    specify { expect(app).to have_received(:call).with env }
  end

  context 'when sensitive data is detected' do
    let(:sensitive_data?) { false }
    specify { expect(parameter_masker).not_to have_received :mask! }
    specify { expect(SensitiveDataFilter).not_to have_received(:handle_occurrence) }
    specify { expect(app).to have_received(:call).with env }
  end
end
