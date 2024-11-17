# frozen_string_literal: true

require_relative 'lib/mysql_casual_explain/version'

Gem::Specification.new do |spec|
  spec.name          = 'mysql_casual_explain'
  spec.version       = MysqlCasualExplain::VERSION
  spec.authors       = ['winebarrel']
  spec.email         = ['sugawara@winebarrel.jp']

  spec.summary       = 'Highlight problematic MySQL explain results.'
  spec.description   = 'Highlight problematic MySQL explain results.'
  spec.homepage      = 'https://github.com/winebarrel/mysql_casual_explain'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 3.1.0')

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activerecord', '>= 6.1'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
