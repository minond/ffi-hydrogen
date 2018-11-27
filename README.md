[![Build Status](https://travis-ci.org/minond/ffi-hydrogen.svg?branch=master)](https://travis-ci.org/minond/ffi-hydrogen)

# FFI::Hydrogen

Combine [libhydrogen](https://github.com/jedisct1/libhydrogen) with a good
implementation of string encoding in C, Nick Galbreath's
[base64](https://github.com/client9/stringencoders) implementation in this
case, and the end result is hopefully a fast method of encrypting data in a way
that is URL safe.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "ffi-hydrogen"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ffi-hydrogen

## Usage

```ruby
key = ::FFI::Hydrogen.hydro_secretbox_keygen
context = "examples"

message = "0123456789"
encrypted = ::FFI::Hydrogen.hydro_secretbox_encrypt(message, context, key)
encoded = ::FFI::Hydrogen.modp_b64_encode(encrypted)
decoded = ::FFI::Hydrogen.modp_b64_decode(encoded)
decrypted = ::FFI::Hydrogen.hydro_secretbox_decrypt(decoded, context, key)

puts "message: #{message}"
puts "encrypted: #{encrypted}"
puts "encoded: #{encoded}"
puts "decoded: #{decoded}"
puts "decrypted: #{decrypted}"
```

### `::FFI::Hydrogen::Secretbox`

```ruby
ctx = "examples"
key = ::FFI::Hydrogen.hydro_secretbox_keygen
box = ::FFI::Hydrogen::Secretbox.new(ctx, key)

message = "0123456789"
boxed = box.encrypt_encode(message)
unboxed = box.decode_decrypt(boxed)

puts "message: #{message}"
puts "boxed: #{boxed}"
puts "unboxed: #{unboxed}"
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake spec` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `ffi-hydrogen.gemspec`, and
then run `bundle exec rake release`, which will create a git tag for the
version, push git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).
