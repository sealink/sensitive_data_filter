# coding: utf-8
# frozen_string_literal: true
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sensitive_data_filter/version'

Gem::Specification.new do |spec|
  spec.name          = 'sensitive_data_filter'
  spec.version       = SensitiveDataFilter::VERSION
  spec.authors       = ['Alessandro Berardi']
  spec.email         = ['berardialessandro@gmail.com']

  spec.summary       = 'Rack Middleware filter for sensitive data'
  spec.description   = 'A Rack Middleware level Rails filter for sensitive data'
  spec.homepage      = 'https://github.com/sealink/sensitive_data_filter'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
                                        .reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.5'
  spec.add_development_dependency 'rubocop', '~> 0.46'
end
