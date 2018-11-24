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

    # size_t modp_b64_encode(char* dest, const char* str, size_t len)
    attach_function :_modp_b64_encode, :modp_b64_encode, [:pointer, :pointer, :size_t], :size_t

    # size_t modp_b64_decode(char* dest, const char* src, size_t len)
    attach_function :_modp_b64_decode, :modp_b64_decode, [:pointer, :pointer, :size_t], :size_t

    # size_t encrypt_encode(char* dest, const char* message, size_t message_len,
    #                       uint64_t message_id,
    #                       const char context[hydro_secretbox_CONTEXTBYTES],
    #                       const uint8_t key[hydro_secretbox_KEYBYTES])
    attach_function :_encrypt_encode, :encrypt_encode, [:pointer, :pointer, :size_t, :uint64, :pointer, :pointer], :size_t

    # size_t decode_decrypt(char* dest, const void* message, size_t message_len,
    #                       uint64_t message_id,
    #                       const char context[hydro_secretbox_CONTEXTBYTES],
    #                       const uint8_t key[hydro_secretbox_KEYBYTES])
    attach_function :_decode_decrypt, :decode_decrypt, [:pointer, :pointer, :size_t, :uint64, :pointer, :pointer], :size_t

    def self.encrypt_encode(text, context, key, message_id = 0)
      result = nil
      text_len = text.bytesize
      max_len = modp_b64_encode_len(text_len + HEADERBYTES)

      create_key(key) do |key_ptr|
        create_context(context) do |context_ptr|
          create_string_and_buffer(text, max_len) do |text_ptr, buff_ptr|
            size = _encrypt_encode(buff_ptr, text_ptr, text_len, message_id, context_ptr, key_ptr)
            result = buff_ptr.get_bytes(0, size)
          end
        end
      end

      result
    end

    def self.decode_decrypt(text, context, key, message_id = 0)
      result = nil
      text_len = text.bytesize
      max_len = modp_b64_decode_len(text_len)

      create_key(key) do |key_ptr|
        create_context(context) do |context_ptr|
          create_string_and_buffer(text, max_len) do |text_ptr, buff_ptr|
            size = _decode_decrypt(buff_ptr, text_ptr, text_len, message_id, context_ptr, key_ptr)
            result = buff_ptr.get_bytes(0, size)
          end
        end
      end

      result
    end

    def self.modp_b64_encode(text)
      encoded = nil
      text_len = text.bytesize
      buff_len = modp_b64_encode_len(text_len)

      create_string_and_buffer(text, buff_len) do |text_ptr, buff_ptr|
        size = ::FFI::HydrogenEncoder._modp_b64_encode(buff_ptr, text_ptr, text_len)
        encoded = buff_ptr.get_bytes(0, size)
      end

      encoded
    end

    def self.modp_b64_decode(text)
      decoded = nil
      text_len = text.bytesize
      buff_len = modp_b64_decode_len(text_len)

      create_string_and_buffer(text, buff_len) do |text_ptr, buff_ptr|
        size = ::FFI::HydrogenEncoder._modp_b64_decode(buff_ptr, text_ptr, text_len)
        decoded = buff_ptr.get_bytes(0, size)
      end

      decoded
    end

    def self.modp_b64_encode_len(len)
      ((len + 2) / 3 * 4 + 1)
    end

    def self.modp_b64_decode_len(len)
      (len / 4 * 3 + 2)
    end

    def self.hydro_secretbox_keygen
      key = nil

      ::FFI::MemoryPointer.new(:char, KEYBYTES) do |buff|
        ::FFI::HydrogenEncoder._hydro_secretbox_keygen(buff)
        key = buff.get_bytes(0, KEYBYTES)
      end

      key
    end

    def self.hydro_secretbox_encrypt(text, context, key, message_id = 0)
      encrypted = nil
      cipher_len = HEADERBYTES + text.bytesize

      ::FFI::MemoryPointer.new(:uint8, cipher_len) do |cipher_ptr|
        ::FFI::MemoryPointer.new(:char, text.bytesize) do |text_ptr|
          text_ptr.put_bytes(0, text)

          create_context(context) do |context_ptr|
            create_key(key) do |key_ptr|
              ::FFI::HydrogenEncoder._hydro_secretbox_encrypt(cipher_ptr, text_ptr, text.bytesize, message_id, context_ptr, key_ptr)
              encrypted = cipher_ptr.get_bytes(0, cipher_len)
            end
          end
        end
      end

      encrypted
    end

    def self.hydro_secretbox_decrypt(cipher_text, context, key, message_id = 0)
      encrypted = nil
      cipher_len = cipher_text.bytesize - HEADERBYTES

      ::FFI::MemoryPointer.new(:char, cipher_len) do |text_ptr|
        ::FFI::MemoryPointer.new(:uint8, cipher_text.bytesize) do |cipher_ptr|
          cipher_ptr.put_bytes(0, cipher_text)

          create_context(context) do |context_ptr|
            create_key(key) do |key_ptr|
              ::FFI::HydrogenEncoder._hydro_secretbox_decrypt(text_ptr, cipher_ptr, cipher_text.bytesize, message_id, context_ptr, key_ptr)
              encrypted = text_ptr.get_bytes(0, cipher_len)
            end
          end
        end
      end

      encrypted
    end

    def self.create_context(context)
      return yield(context) if context.is_a?(::FFI::MemoryPointer)

      ::FFI::MemoryPointer.new(:char, context.bytesize) do |context_ptr|
        context_ptr.put_bytes(0, context)
        yield(context_ptr)
      end
    end

    def self.create_key(key)
      return yield(key) if key.is_a?(::FFI::MemoryPointer)

      ::FFI::MemoryPointer.new(:uint8, key.bytesize) do |key_ptr|
        key_ptr.put_bytes(0, key)
        yield(key_ptr)
      end
    end

    def self.create_string_and_buffer(text, buff_size)
      ::FFI::MemoryPointer.new(:char, buff_size) do |buff_ptr|
        ::FFI::MemoryPointer.new(:char, text.bytesize) do |text_ptr|
          text_ptr.put_bytes(0, text)
          yield(text_ptr, buff_ptr)
        end
      end
    end

    class Secretbox
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

      def encrypt_encode(text, message_id = 0)
        ::FFI::HydrogenEncoder.encrypt_encode(text, @context_ptr, @key_ptr, message_id)
      end

      def decode_decrypt(text, message_id = 0)
        ::FFI::HydrogenEncoder.decode_decrypt(text, @context_ptr, @key_ptr, message_id)
      end
    end
  end
end
