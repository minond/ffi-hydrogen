require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rubocop/rake_task"

RSpec::Core::RakeTask.new(:spec)

desc "Run RuboCop"
task :rubocop do
  RuboCop::RakeTask.new
end

task :default => [:rubocop, :spec]
