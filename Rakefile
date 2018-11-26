require "bundler/gem_tasks"
require "ffi"
require "rspec/core/rake_task"
require "rubocop/rake_task"

def sys(cmd)
  puts "#{cmd}"
  ret = system(cmd)
  raise "ERROR: '#{cmd}' failed" unless ret
  ret
end

RSpec::Core::RakeTask.new(:spec)

desc "Run RuboCop"
task :rubocop do
  RuboCop::RakeTask.new
end

desc "Compile shared library"
task :compile do
  wflags = "-Wall -Wextra -Wmissing-prototypes -Wdiv-by-zero"\
    " -Wbad-function-cast -Wcast-align -Wcast-qual -Wfloat-equal"\
    " -Wmissing-declarations -Wnested-externs -Wno-unknown-pragmas"\
    " -Wpointer-arith -Wredundant-decls -Wstrict-prototypes -Wswitch-enum"\
    " -Wno-type-limits"

  cflags = "-O3 -march=native -fPIC -fno-exceptions #{wflags}"

  # main.o: main.c
  #   $(CC) -c $(CFLAGS) $< -o $@
  sys("cc -c #{cflags} vendor/main.c -o vendor/main.o")

  # main.dylib: main.o
  # 	$(CC) $< -shared -o $@
  sys("cc vendor/main.o -shared -o vendor/main.#{::FFI::Platform::LIBSUFFIX}")
end

desc "Run all benchmarks"
task :bench do
  ruby "bench/both.rb"
  ruby "bench/encode.rb"
  ruby "bench/encrypt.rb"
end

task :default => [:compile, :rubocop, :spec]
