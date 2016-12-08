# frozen_string_literal: true
# rubocop:disable Style/BlockDelimiters
require 'spec_helper'

require 'sensitive_data_filter/middleware/filter'

describe SensitiveDataFilter::Middleware::Filter do
  let(:env_filter_class) { double }
  let(:env_filter)       {
    double occurrence?: occurrence?, occurrence: occurrence, clean_env: clean_env
  }
  let(:occurrence) { double }
  let(:clean_env)  { double 'clean_env' }

  let(:app)         { double }
  let(:middleware)  { SensitiveDataFilter::Middleware::Filter }
  let(:stack)       { middleware.new(app) }
  let(:env)         { double }

  before do
    stub_const 'SensitiveDataFilter::Middleware::EnvFilter', env_filter_class
    allow(env_filter_class).to receive(:new).with(env).and_return env_filter
    allow(SensitiveDataFilter).to receive(:handle_occurrence).with occurrence
    allow(app).to receive(:call).with clean_env
    stack.call(env)
  end

  context 'when an occurrence is detected' do
    let(:occurrence?) { true }
    specify { expect(SensitiveDataFilter).to have_received(:handle_occurrence).with occurrence }
    specify { expect(app).to have_received(:call).with clean_env }
  end

  context 'when sensitive data is detected' do
    let(:occurrence?) { false }
    specify { expect(SensitiveDataFilter).not_to have_received(:handle_occurrence) }
    specify { expect(app).to have_received(:call).with clean_env }
  end
end
