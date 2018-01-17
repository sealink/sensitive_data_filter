# frozen_string_literal: true
# rubocop:disable Style/BlockDelimiters
require 'spec_helper'

require 'sensitive_data_filter/middleware/filter'

describe SensitiveDataFilter::Middleware::Filter do
  let(:env_parser_class) { double }
  let(:env_parser)       {
    double 'EnvParser'
  }
  let(:occurrence)   { double 'Occurrence' }
  let(:occurrence_class) { double }
  let(:filtered_env) { double 'filtered_env' }

  let(:app)         { double 'App' }
  let(:middleware)  { SensitiveDataFilter::Middleware::Filter }
  let(:stack)       { middleware.new(app) }
  let(:env)         { double 'Env' }

  let(:detect) { double }
  let(:detect_class) { double }

  let(:scan) { double('Scam', matches: []) }
  let(:changeset) { double('Changeset') }


  before do
    stub_const 'SensitiveDataFilter::Middleware::Detect', detect_class
    stub_const 'SensitiveDataFilter::Middleware::EnvParser', env_parser_class

    allow(SensitiveDataFilter).to receive(:handle_occurrence).with occurrence
    allow(env_parser_class).to receive(:new).and_return(env_parser)
    allow(detect_class).to receive(:new).with(env_parser).and_return detect
    allow(detect).to receive(:call).and_return [changeset, scan]

    allow(env_parser).to receive(:mutate).with(changeset)

    stub_const 'SensitiveDataFilter::Middleware::Occurrence', occurrence_class
    allow(occurrence_class)
      .to receive(:new).with(env_parser, changeset, scan.matches).and_return occurrence

    allow(app).to receive(:call).with env
    stack.call(env)
  end

  context 'when an occurrence is detected' do
    let(:changeset) { double }
    specify { expect(SensitiveDataFilter).to have_received(:handle_occurrence).with occurrence }
    specify { expect(app).to have_received(:call).with env }
  end

  context 'when sensitive data is detected' do
    let(:changeset) { nil }
    specify { expect(SensitiveDataFilter).not_to have_received(:handle_occurrence) }
    specify { expect(app).to have_received(:call).with env }
  end
end
