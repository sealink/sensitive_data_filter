# coding: utf-8
# frozen_string_literal: true
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sensitive_data_filter/version'

Gem::Specification.new do |spec|
  spec.name          = 'sensitive_data_filter'
  spec.version       = SensitiveDataFilter::VERSION
  spec.authors       = ['Alessandro Berardi', 'SeaLink ']
  spec.email         = %w(berardialessandro@gmail.com support@travellink.com.au)

  spec.summary       = 'Rack Middleware filter for sensitive data'
  spec.description   = 'A Rack Middleware level filter for sensitive data'
  spec.homepage      = 'https://github.com/sealink/sensitive_data_filter'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
                                        .reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 3.0'

  spec.add_dependency 'rack'
  spec.add_dependency 'facets'
  spec.add_dependency 'credit_card_validations'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'coverage-kit'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'pry'
end
