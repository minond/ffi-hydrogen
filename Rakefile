require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rubocop/rake_task"

import "ext/ffi/hydrogen/Rakefile"

RSpec::Core::RakeTask.new(:spec)

desc "Compile shared library"
task :compile do
  Rake::Task[:compile_shared].invoke
end

desc "Run RuboCop"
task :rubocop do
  RuboCop::RakeTask.new
end

task :default => [:compile, :rubocop, :spec]
