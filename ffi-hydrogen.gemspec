lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "ffi-hydrogen"
  spec.version       = "0.1.3"
  spec.authors       = ["Marcos Minond"]
  spec.email         = ["marcos.minond@mx.com"]

  spec.summary       = "libhydrogen + encoding = cryptographically sound, URL safe string = libhydrogen + encoding"
  spec.homepage      = "https://github.com/minond/ffi-hydrogen"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path("..", __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.extensions    = "ext/ffi/hydrogen/Rakefile"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "ffi"

  spec.add_development_dependency "benchmark-ips", "~> 2.7.2"
  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "mad_rubocop"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rbnacl", "~> 6.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "urlcrypt"
end
