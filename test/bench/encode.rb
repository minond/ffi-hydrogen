require "base64"
require "benchmark/ips"

require "ffi/hydrogen_encoder"

Benchmark.ips do |b|
  b.time = 2
  b.warmup = 1

  ten_char = "0123456789"
  fifty_char = "<abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuv>"
  hundred_char = "<abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz0123456789!@#^&*()_+>"

  def suite(b, label, text)
    encoded = ::FFI::HydrogenEncoder.modp_b64_encode(text)

    b.report("modp_b64_encode_#{label}") do |n|
      i = 0
      while i < n
        ::FFI::HydrogenEncoder.modp_b64_encode(text)
        i += 1
      end
    end

    b.report("modp_b64_decode_#{label}") do |n|
      i = 0
      while i < n
        ::FFI::HydrogenEncoder.modp_b64_decode(encoded)
        i += 1
      end
    end

    b.report("base64_encode64_#{label}") do |n|
      i = 0
      while i < n
        ::Base64.encode64(text)
        i += 1
      end
    end

    b.report("base64_decode64_#{label}") do |n|
      i = 0
      while i < n
        ::Base64.decode64(text)
        i += 1
      end
    end
  end

  suite(b, :ten_char, ten_char)
  suite(b, :fifty_char, fifty_char)
  suite(b, :hundred_char, hundred_char)

  b.compare!
end
