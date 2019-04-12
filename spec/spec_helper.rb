# frozen_string_literal: true

require 'simplecov'
if %w[1 true yes on].include?(ENV.fetch('CODE_COVERAGE', 'no'))
  SimpleCov.add_filter 'spec' # we don't need coverage on our specs or any supporting files
  SimpleCov.start
end

require "bundler/setup"
require 'rspec'

RSpec.configure do |config|
  config.default_formatter = 'doc' if config.files_to_run.one?
  config.pending_color = :magenta
  config.example_status_persistence_file_path = '.rspec_status'
  config.disable_monkey_patching!
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
