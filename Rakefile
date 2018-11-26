require "bundler/gem_tasks"
require "ffi"
require "rspec/core/rake_task"
require "rubocop/rake_task"

RSpec::Core::RakeTask.new(:spec)

desc "Run RuboCop"
task :rubocop do
  RuboCop::RakeTask.new
end

def sys(cmd)
  puts "#{cmd}"
  unless ret = system(cmd)
    raise "ERROR: '#{cmd}' failed"
  end
  ret
end

desc "Compile Shared Library"
task :compile do
  wflags = %q{-Wall -Wextra -Wmissing-prototypes -Wdiv-by-zero \
    -Wbad-function-cast -Wcast-align -Wcast-qual -Wfloat-equal \
    -Wmissing-declarations -Wnested-externs -Wno-unknown-pragmas \
    -Wpointer-arith -Wredundant-decls -Wstrict-prototypes -Wswitch-enum \
    -Wno-type-limits}

  cflags = "-O3 -march=native -fno-exceptions #{wflags}"

  # main.o: main.c
  #   $(CC) -c $(CFLAGS) $< -o $@
  sys("cc -c #{cflags} vendor/main.c -o vendor/main.o")

  # main.dylib: main.o
  # 	$(CC) $< -shared -o $@
  sys("cc vendor/main.o -shared -o vendor/main.#{::FFI::Platform::LIBSUFFIX}")
end

Rake::Task[:spec].prerequisites << :compile

task :default => [:rubocop, :spec]
