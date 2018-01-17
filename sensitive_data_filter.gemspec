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

  spec.required_ruby_version = '>= 2.1'

  spec.add_dependency 'rack', '>= 1.4'
  spec.add_dependency 'facets', '~> 3.1'
  spec.add_dependency 'credit_card_validations', '~> 3.4'

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.5'
  spec.add_development_dependency 'coverage-kit', '~> 0.1'
  spec.add_development_dependency 'simplecov-rcov', '~> 0.2'
  spec.add_development_dependency 'coveralls', '~> 0.8'
  spec.add_development_dependency 'rubocop', '~> 0.52'
  spec.add_development_dependency 'travis', '~> 1.8'
end
