require "base64"
require "benchmark/ips"
require "rbnacl"
require "urlcrypt"

require "ffi/hydrogen_encoder"

require "./test/bench/init.rb"

def suite(str)
  puts "============================ Test string length: #{str.size} ============================"

  label = "#{str.size}_char"

  hydrogen_key = ::FFI::HydrogenEncoder.hydro_secretbox_keygen
  hydrogen_context = "benched1"
  hydrogen_box = ::FFI::HydrogenEncoder::Secretbox.new(hydrogen_context, hydrogen_key)
  hydrogen_encrypted_encoded = hydrogen_box.encrypt_encode(str)

  rbnacl_key = ::RbNaCl::Random.random_bytes(::RbNaCl::SecretBox.key_bytes)
  rbnacl_box = ::RbNaCl::SimpleBox.from_secret_key(rbnacl_key)
  rbnacl_encrypted_encoded = ::Base64.encode64(rbnacl_box.encrypt(str))

  urlcrypt_key = "h34j4k3l25gh342o5jk46ghjk5nbjkl7nhljk34532j4k5b43hjk5g432jk6v4gjhk6f5j6gv5hj2k3g54hjk321g4hjk25g4hjk35gf4yu6f5jg5b43jk25h4jk325d"
  ::URLcrypt.key = [urlcrypt_key].pack("H*")
  urlcrypt_encrypted = ::URLcrypt.encrypt(str)

  Benchmark.ips do |b|
    b.time = 2
    b.warmup = 1

    b.report("boxed_encrypt_encode_#{label}") do |n|
      i = 0
      while i < n
        hydrogen_box.encrypt_encode(str)
        i += 1
      end
    end

    b.report("boxed_decode_decrypt_#{label}") do |n|
      i = 0
      while i < n
        hydrogen_box.decode_decrypt(hydrogen_encrypted_encoded)
        i += 1
      end
    end

    b.report("urlcrypt_encrypt_#{label}") do |n|
      i = 0
      while i < n
        ::URLcrypt.encrypt(str)
        i += 1
      end
    end

    b.report("urlcrypt_decrypt_#{label}") do |n|
      i = 0
      while i < n
        ::URLcrypt.decrypt(urlcrypt_encrypted)
        i += 1
      end
    end

    b.report("boxed_rbnacl_simplebox_encrypt_plus_base64_#{label}") do |n|
      i = 0
      while i < n
        ::Base64.encode64(rbnacl_box.encrypt(str))
        i += 1
      end
    end

    b.report("boxed_rbnacl_simplebox_decrypt_plus_base64_#{label}") do |n|
      i = 0
      while i < n
        rbnacl_box.decrypt(::Base64.decode64(rbnacl_encrypted_encoded))
        i += 1
      end
    end

    b.compare!
  end
end

TEST_STRINGS.each do |str|
  suite(str)
end
