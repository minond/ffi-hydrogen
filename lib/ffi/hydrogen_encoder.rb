require "ffi"
require "ffi/hydrogen_encoder/version"

module FFI
  module HydrogenEncoder
    extend FFI::Library

    # define hydro_secretbox_KEYBYTES 32
    # define hydro_secretbox_HEADERBYTES (20 + 16)
    KEYBYTES = 32
    HEADERBYTES = 36

    ffi_lib "vendor/main.#{::FFI::Platform::LIBSUFFIX}"

    # void hydro_secretbox_keygen(uint8_t key[hydro_secretbox_KEYBYTES])
    attach_function :_hydro_secretbox_keygen, :hydro_secretbox_keygen, [:pointer], :void

    # int hydro_secretbox_encrypt(uint8_t *c, const void *m_, size_t mlen, uint64_t msg_id,
    #                             const char    ctx[hydro_secretbox_CONTEXTBYTES],
    #                             const uint8_t key[hydro_secretbox_KEYBYTES])
    attach_function :_hydro_secretbox_encrypt, :hydro_secretbox_encrypt, [:pointer, :pointer, :size_t, :uint64, :pointer, :pointer], :int32

    # int hydro_secretbox_decrypt(void *m_, const uint8_t *c, size_t clen, uint64_t msg_id,
    #                             const char    ctx[hydro_secretbox_CONTEXTBYTES],
    #                             const uint8_t key[hydro_secretbox_KEYBYTES])
    attach_function :_hydro_secretbox_decrypt, :hydro_secretbox_decrypt, [:pointer, :pointer, :size_t, :uint64, :pointer, :pointer], :int32

    def self.hydro_secretbox_keygen
      key = nil

      ::FFI::MemoryPointer.new(:char, KEYBYTES) do |buff|
        ::FFI::HydrogenEncoder._hydro_secretbox_keygen(buff)
        key = buff.get_bytes(0, KEYBYTES)
      end

      key
    end

    class Manager
      def initialize(context, key)
        @context_ptr = ::FFI::MemoryPointer.new(:char, context.bytesize)
        @context_ptr.put_bytes(0, context)
        @key_ptr = ::FFI::MemoryPointer.new(:uint8, key.bytesize)
        @key_ptr.put_bytes(0, key)
      end

      def encrypt(text)
        ::FFI::HydrogenEncoder.hydro_secretbox_encrypt(text, @context_ptr, @key_ptr)
      end

      def decrypt(text)
        ::FFI::HydrogenEncoder.hydro_secretbox_decrypt(text, @context_ptr, @key_ptr)
      end
    end

    def self.hydro_secretbox_encrypt(text, context, key)
      encrypted = nil
      cipher_len = HEADERBYTES + text.bytesize

      ::FFI::MemoryPointer.new(:uint8, cipher_len) do |cipher_ptr|
        ::FFI::MemoryPointer.new(:char, text.bytesize) do |text_ptr|
          text_ptr.put_bytes(0, text)

          create_context(context) do |context_ptr|
            create_key(key) do |key_ptr|
              ::FFI::HydrogenEncoder._hydro_secretbox_encrypt(cipher_ptr, text_ptr, text.bytesize, 0, context_ptr, key_ptr)
              encrypted = cipher_ptr.get_bytes(0, cipher_len)
            end
          end
        end

      end

      encrypted
    end

    def self.hydro_secretbox_decrypt(cipher_text, context, key)
      encrypted = nil
      cipher_len = cipher_text.bytesize - HEADERBYTES

      ::FFI::MemoryPointer.new(:char, cipher_len) do |text_ptr|
        ::FFI::MemoryPointer.new(:uint8, cipher_text.bytesize) do |cipher_ptr|
          cipher_ptr.put_bytes(0, cipher_text)

          create_context(context) do |context_ptr|
            create_key(key) do |key_ptr|
              ::FFI::HydrogenEncoder._hydro_secretbox_decrypt(text_ptr, cipher_ptr, cipher_text.bytesize, 0, context_ptr, key_ptr)
              encrypted = text_ptr.get_bytes(0, cipher_len)
            end
          end
        end
      end

      encrypted
    end

    def self.create_context(context)
      if context.is_a?(::FFI::MemoryPointer)
        return yield(context)
      end

      ::FFI::MemoryPointer.new(:char, context.bytesize) do |context_ptr|
        context_ptr.put_bytes(0, context)
        yield(context_ptr)
      end
    end

    def self.create_key(key)
      if key.is_a?(::FFI::MemoryPointer)
        return yield(key)
      end

      ::FFI::MemoryPointer.new(:uint8, key.bytesize) do |key_ptr|
        key_ptr.put_bytes(0, key)
        yield(key_ptr)
      end
    end
  end
end
