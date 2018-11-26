require "base64"
require "benchmark/ips"

require "ffi/hydrogen_encoder"

require "./test/bench/init.rb"

def suite(text)
  puts "============================ Test string length: #{text.size} ============================"

  label = "#{text.size}_char"

  encoded = ::FFI::HydrogenEncoder.modp_b64_encode(text)

  Benchmark.ips do |b|
    b.time = 2
    b.warmup = 1

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

    b.compare!
  end
end

TEST_STRINGS.each do |str|
  suite(str)
end
