RSpec.describe ::FFI::HydrogenEncoder do
  key = ::FFI::HydrogenEncoder.hydro_secretbox_keygen
  str = "j4k3l25hj4l6hgb54jk6ghkj4g5k4h36jk45"
  ctx = "spectest"

  # it "has a version number" do
  #   expect(::FFI::HydrogenEncoder::VERSION).not_to be nil
  # end

  describe "#modp_b64_encode" do
    it "encodes a string so that it does not match the original" do
      encoded = ::FFI::HydrogenEncoder.modp_b64_encode(str)
      expect(encoded).not_to eq(str)
    end
  end

  describe "#modp_b64_decode" do
    it "decodes a string so that is matches the original" do
      encoded = ::FFI::HydrogenEncoder.modp_b64_encode(str)
      decoded = ::FFI::HydrogenEncoder.modp_b64_decode(encoded)
      expect(decoded).to eq(str)
    end
  end

  describe "#hydro_secretbox_encrypt" do
    it "encrypts a string which does not match the original" do
      encrypted = ::FFI::HydrogenEncoder.hydro_secretbox_encrypt(str, ctx, key)
      expect(encrypted).not_to eq(str)
    end

    it "encrypts a string differently when context changes" do
      encrypted1 = ::FFI::HydrogenEncoder.hydro_secretbox_encrypt(str, ctx, key)
      encrypted2 = ::FFI::HydrogenEncoder.hydro_secretbox_encrypt(str, "another1", key)
      expect(encrypted1).not_to eq(encrypted2)
    end

    it "encrypts a string differently when message_id changes" do
      encrypted1 = ::FFI::HydrogenEncoder.hydro_secretbox_encrypt(str, ctx, key, 0)
      encrypted2 = ::FFI::HydrogenEncoder.hydro_secretbox_encrypt(str, ctx, key, 1)
      expect(encrypted1).not_to eq(encrypted2)
    end
  end

  describe "#hydro_secretbox_decrypt" do
    it "decrypts a string which matches the original" do
      encrypted = ::FFI::HydrogenEncoder.hydro_secretbox_encrypt(str, ctx, key)
      decrypted = ::FFI::HydrogenEncoder.hydro_secretbox_decrypt(encrypted, ctx, key)
      expect(decrypted).to eq(str)
    end

    it "encrypts a string differently when context and message_id changes" do
      encrypted = ::FFI::HydrogenEncoder.hydro_secretbox_encrypt(str, "another1", key, 1)
      decrypted = ::FFI::HydrogenEncoder.hydro_secretbox_decrypt(encrypted, "another1", key, 1)
      expect(decrypted).to eq(str)
    end

    it "fails to decrypt when context does not match" do
      encrypted = ::FFI::HydrogenEncoder.hydro_secretbox_encrypt(str, ctx, key)
      decrypted = ::FFI::HydrogenEncoder.hydro_secretbox_decrypt(encrypted, "another1", key)
      expect(decrypted).not_to eq(str)
    end

    it "fails to decrypt when message_id does not match" do
      encrypted = ::FFI::HydrogenEncoder.hydro_secretbox_encrypt(str, ctx, key, 1)
      decrypted = ::FFI::HydrogenEncoder.hydro_secretbox_decrypt(encrypted, ctx, key, 2)
      expect(decrypted).not_to eq(str)
    end
  end

  describe ::FFI::HydrogenEncoder::Secretbox do
    box = ::FFI::HydrogenEncoder::Secretbox.new(ctx, key)

    describe "#encrypt" do
      it "encrypts a string which does not match the original" do
        encrypted = box.encrypt(str)
        expect(encrypted).not_to eq(str)
      end

      it "encrypts a string differently when message_id changes" do
        encrypted1 = box.encrypt(str, 1)
        encrypted2 = box.encrypt(str, 2)
        expect(encrypted1).not_to eq(encrypted2)
      end
    end

    describe "#decrypt" do
      it "decrypts a string which matches the original" do
        encrypted = box.encrypt(str)
        decrypted = box.decrypt(encrypted)
        expect(decrypted).to eq(str)
      end

      it "fails to decrypt when message_id does not match" do
        encrypted = box.encrypt(str, 1)
        decrypted = box.decrypt(encrypted, 2)
        expect(decrypted).not_to eq(str)
      end
    end

    describe "#encrypt_encode" do
      it "encrypts/encodes a string which does not match the original" do
        encrypted = box.encrypt_encode(str)
        expect(encrypted).not_to eq(str)
      end

      it "encrypts a string differently when message_id changes" do
        encrypted1 = box.encrypt_encode(str, 1)
        encrypted2 = box.encrypt_encode(str, 2)
        expect(encrypted1).not_to eq(encrypted2)
      end
    end

    describe "#decode_decrypt" do
      it "decodes/decrypts a string which matches the original" do
        encrypted = box.encrypt_encode(str)
        decrypted = box.decode_decrypt(encrypted)
        expect(decrypted).to eq(str)
      end

      it "fails to decrypt when message_id does not match" do
        encrypted = box.encrypt_encode(str, 1)
        decrypted = box.decode_decrypt(encrypted, 2)
        expect(decrypted).not_to eq(str)
      end
    end
  end
end
