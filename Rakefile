require "bundler/gem_tasks"
require "rspec/core/rake_task"
require 'yard'

# Local CI testing

namespace :ci do
  desc "Check CIRCLECI config"
  task :check do
    sh "circleci config validate", verbose: true
  end

  desc "Run CIRCLECI config locally"
  task :local do
    sh "circleci local execute", verbose: true
  end
end

# add spec unit tests

RSpec::Core::RakeTask.new(:spec)

# add spec extensions

namespace :spec do
  # add code coverage

  desc "run Simplecov"
  task :coverage do
    sh 'CODE_COVERAGE=1 bundle exec rake spec'
  end
end

# add yard task

YARD::Rake::YardocTask.new do |t|
  t.files = ['README.md', 'lib/**/*.rb']
  t.stats_options = ['--list-undoc']
end

task default: :spec
