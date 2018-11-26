require "benchmark/ips"
require "rbnacl"
require "urlcrypt"

require "ffi/hydrogen_encoder"

Benchmark.ips do |b|
  b.time = 2
  b.warmup = 1

  ten_char = "0123456789"
  fifty_char = "<abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuv>"
  hundred_char = "<abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz0123456789!@#^&*()_+>"

  def suite(b, label, text)
    hydrogen_key = ::FFI::HydrogenEncoder.hydro_secretbox_keygen
    hydrogen_context = "benched1"
    hydrogen_box = ::FFI::HydrogenEncoder::Secretbox.new(hydrogen_context, hydrogen_key)
    hydrogen_encrypted = hydrogen_box.encrypt(text)
    hydrogen_encrypted_encoded = hydrogen_box.encrypt_encode(text)

    rbnacl_key = ::RbNaCl::Random.random_bytes(::RbNaCl::SecretBox.key_bytes)
    rbnacl_box = ::RbNaCl::SimpleBox.from_secret_key(rbnacl_key)
    rbnacl_encrypted = rbnacl_box.encrypt(text)

    urlcrypt_key = "h34j4k3l25gh342o5jk46ghjk5nbjkl7nhljk34532j4k5b43hjk5g432jk6v4gjhk6f5j6gv5hj2k3g54hjk321g4hjk25g4hjk35gf4yu6f5jg5b43jk25h4jk325d"
    ::URLcrypt.key = [urlcrypt_key].pack("H*")
    urlcrypt_encrypted = ::URLcrypt.encrypt(text)

    b.report("boxed_encrypt_encode_#{label}") do |n|
      i = 0
      while i < n
        hydrogen_box.encrypt_encode(text)
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
        ::URLcrypt.encrypt(text)
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

    b.report("hydro_secretbox_encrypt_#{label}") do |n|
      i = 0
      while i < n
        ::FFI::HydrogenEncoder.hydro_secretbox_encrypt(text, hydrogen_context, hydrogen_key)
        i += 1
      end
    end

    b.report("hydro_secretbox_decrypt_#{label}") do |n|
      i = 0
      while i < n
        ::FFI::HydrogenEncoder.hydro_secretbox_decrypt(hydrogen_encrypted, hydrogen_context, hydrogen_key)
        i += 1
      end
    end

    b.report("boxed_hydro_secretbox_encrypt_#{label}") do |n|
      i = 0
      while i < n
        hydrogen_box.encrypt(text)
        i += 1
      end
    end

    b.report("boxed_hydro_secretbox_decrypt_#{label}") do |n|
      i = 0
      while i < n
        hydrogen_box.decrypt(hydrogen_encrypted)
        i += 1
      end
    end

    b.report("boxed_rbnacl_simplebox_encrypt_#{label}") do |n|
      i = 0
      while i < n
        rbnacl_box.encrypt(text)
        i += 1
      end
    end

    b.report("boxed_rbnacl_simplebox_decrypt_#{label}") do |n|
      i = 0
      while i < n
        rbnacl_box.decrypt(rbnacl_encrypted)
        i += 1
      end
    end
  end

  suite(b, :ten_char, ten_char)
  suite(b, :fifty_char, fifty_char)
  suite(b, :hundred_char, hundred_char)

  b.compare!
end
