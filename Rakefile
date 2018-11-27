require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rubocop/rake_task"

import "vendor/Rakefile"

RSpec::Core::RakeTask.new(:spec)

desc "Compile shared library"
task :compile do
  Rake::Task[:compile_shared].invoke
end

desc "Run RuboCop"
task :rubocop do
  RuboCop::RakeTask.new
end

desc "Run all benchmarks"
task :bench do
  ruby "bench/both.rb"
  ruby "bench/encode.rb"
  ruby "bench/encrypt.rb"
end

task :default => [:compile, :rubocop, :spec]
