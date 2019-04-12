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
  s.summary       = '[summary]'
  s.description   = '[description]'

  s.files         = Dir.glob('{bin/*,lib/**/*,[A-Z]*}')
  s.platform      = Gem::Platform::RUBY
  s.require_paths = ['lib']
end
