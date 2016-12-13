# frozen_string_literal: true
source 'https://rubygems.org'

# ruby-2.2 compatible gems
gem 'rack', '~> 1.4'
gem 'activemodel', '>= 3', '< 5'
gem 'activesupport', '>= 3', '< 5'

# Specify your gem's dependencies in sensitive_data_filter.gemspec
gemspec path: '../'
