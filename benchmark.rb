require "base64"
require "benchmark/ips"
require "ffi/hydrogen"
require "rbnacl"
require "urlcrypt"

TEST_STRINGS = [
  "0123456789",
  "<abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuv>",
  "<abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz0123456789!@#^&*()_+>",
]

TEST_STRINGS.each do |str|
  puts "============================ Test string length: #{str.size} ============================"

  label = "#{str.size} characters"

  encoded = ::FFI::Hydrogen.modp_b64_encode(str)

  hydrogen_key = ::FFI::Hydrogen.hydro_secretbox_keygen
  hydrogen_context = "benched1"
  hydrogen_box = ::FFI::Hydrogen::Secretbox.new(hydrogen_context, hydrogen_key)
  hydrogen_encrypted = hydrogen_box.encrypt(str)
  hydrogen_encrypted_encoded = hydrogen_box.encrypt_encode(str)

  rbnacl_key = ::RbNaCl::Random.random_bytes(::RbNaCl::SecretBox.key_bytes)
  rbnacl_box = ::RbNaCl::SimpleBox.from_secret_key(rbnacl_key)
  rbnacl_encrypted = rbnacl_box.encrypt(str)
  rbnacl_encrypted_encoded = ::Base64.encode64(rbnacl_box.encrypt(str))

  urlcrypt_key = "h34j4k3l25gh342o5jk46ghjk5nbjkl7nhljk34532j4k5b43hjk5g432jk6v4gjhk6f5j6gv5hj2k3g54hjk321g4hjk25g4hjk35gf4yu6f5jg5b43jk25h4jk325d"
  ::URLcrypt.key = [urlcrypt_key].pack("H*")
  urlcrypt_encrypted = ::URLcrypt.encrypt(str)

  Benchmark.ips do |b|
    b.time = 2
    b.warmup = 1

    b.report("Boxed Hydrogen encrypt_encode (#{label})") do |n|
      i = 0
      while i < n
        hydrogen_box.encrypt_encode(str)
        i += 1
      end
    end

    b.report("Boxed Hydrogen decode_decrypt (#{label})") do |n|
      i = 0
      while i < n
        hydrogen_box.decode_decrypt(hydrogen_encrypted_encoded)
        i += 1
      end
    end

    b.report("Boxed Hydrogen encrypt + Base64 encode (#{label})") do |n|
      i = 0
      while i < n
        hydrogen_box.encrypt(::Base64.encode64(str))
        i += 1
      end
    end

    b.report("Boxed Hydrogen decrypt + Base64 decode (#{label})") do |n|
      i = 0
      while i < n
        ::Base64.decode64(hydrogen_box.decrypt(hydrogen_encrypted_encoded))
        i += 1
      end
    end

    b.report("URLcrypt decrypt (#{label})") do |n|
      i = 0
      while i < n
        ::URLcrypt.encrypt(str)
        i += 1
      end
    end

    b.report("URLcrypt decrypt (#{label})") do |n|
      i = 0
      while i < n
        ::URLcrypt.decrypt(urlcrypt_encrypted)
        i += 1
      end
    end

    b.report("Boxed RbNaCl encrypt + Base64 encode (#{label})") do |n|
      i = 0
      while i < n
        ::Base64.encode64(rbnacl_box.encrypt(str))
        i += 1
      end
    end

    b.report("Boxed RbNaCl decrypt + Base64 decode (#{label})") do |n|
      i = 0
      while i < n
        rbnacl_box.decrypt(::Base64.decode64(rbnacl_encrypted_encoded))
        i += 1
      end
    end

    b.report("modp_b64_encode (#{label})") do |n|
      i = 0
      while i < n
        ::FFI::Hydrogen.modp_b64_encode(str)
        i += 1
      end
    end

    b.report("modp_b64_decode (#{label})") do |n|
      i = 0
      while i < n
        ::FFI::Hydrogen.modp_b64_decode(encoded)
        i += 1
      end
    end

    b.report("Base64 encode (#{label})") do |n|
      i = 0
      while i < n
        ::Base64.encode64(str)
        i += 1
      end
    end

    b.report("Base64 decode (#{label})") do |n|
      i = 0
      while i < n
        ::Base64.decode64(str)
        i += 1
      end
    end

    b.report("hydro_secretbox_encrypt (#{label})") do |n|
      i = 0
      while i < n
        ::FFI::Hydrogen.hydro_secretbox_encrypt(str, hydrogen_context, hydrogen_key)
        i += 1
      end
    end

    b.report("hydro_secretbox_decrypt (#{label})") do |n|
      i = 0
      while i < n
        ::FFI::Hydrogen.hydro_secretbox_decrypt(hydrogen_encrypted, hydrogen_context, hydrogen_key)
        i += 1
      end
    end

    b.report("Boxed Hydrogen encrypt (#{label})") do |n|
      i = 0
      while i < n
        hydrogen_box.encrypt(str)
        i += 1
      end
    end

    b.report("Boxed Hydrogen decrypt (#{label})") do |n|
      i = 0
      while i < n
        hydrogen_box.decrypt(hydrogen_encrypted)
        i += 1
      end
    end

    b.report("Boxed RbNaCl encrypt (#{label})") do |n|
      i = 0
      while i < n
        rbnacl_box.encrypt(str)
        i += 1
      end
    end

    b.report("Boxed RbNaCl decrypt (#{label})") do |n|
      i = 0
      while i < n
        rbnacl_box.decrypt(rbnacl_encrypted)
        i += 1
      end
    end

    b.compare!
  end
end
