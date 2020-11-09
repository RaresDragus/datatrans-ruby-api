# frozen_string_literal: true

require_relative 'lib/datatrans/version'

Gem::Specification.new do |spec|
  spec.name          = 'datatrans-ruby-api'
  spec.version       = Datatrans::VERSION
  spec.authors       = ['Rares Dragus']
  spec.email         = ['rares.dragus@gmail.com']

  spec.summary       = 'Datatrans Ruby API Library.'
  spec.description   = 'Datatrans API Library for Ruby.'
  spec.homepage      = 'https://www.datatrans.ch'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.4.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/RaresDragus/datatrans-ruby-api'
  spec.metadata['documentation_uri'] = 'https://docs.datatrans.ch/docs'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport'
  spec.add_dependency 'faraday'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'factory_bot'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'yard'
end
