# encoding: utf-8

$:.unshift File.expand_path('../lib', __FILE__)
require 'blank_empty_nil_filters/version'

Gem::Specification.new do |s|
  s.name          = 'blank_empty_nil_filters'
  s.version       = BlankEmptyNilFilters::VERSION
  s.authors       = ['Alan Stebbens']
  s.email         = ['aks@stebbens.org']
  s.homepage      = 'https://github.com/aks/blank_empty_nil_filters'
  s.licenses      = ['MIT']
  s.summary       = 'Extensions for filtering empty, blank, and nil values from Hashes and Arrays',
  s.description   = <<~TEXT
                    Extentions for convenient filtering of blank, empty, and nil values from
                    Hash and Array instances.
                  TEXT

  s.files         = Dir.glob('{bin/*,lib/**/*,[A-Z]*}')
  s.platform      = Gem::Platform::RUBY
  s.require_paths = ['lib']

  s.add_development_dependency "bundler"
  s.add_development_dependency "fuubar"
  s.add_development_dependency "guard"
  s.add_development_dependency "guard-rspec"
  s.add_development_dependency "guard-yard"
  s.add_development_dependency "pry-byebug"
  s.add_development_dependency "rake"
  s.add_development_dependency "redcarpet"
  s.add_development_dependency "rspec"
  s.add_development_dependency "rspec_junit"
  s.add_development_dependency "rspec_junit_formatter"
  s.add_development_dependency "rubocop"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "spring"
  s.add_development_dependency "terminal-notifier-guard" if /Darwin/.match?(`uname -a`.strip)
  s.add_development_dependency "yard"
end
