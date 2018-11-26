RSpec.describe ::FFI::HydrogenEncoder do
  key = ::FFI::HydrogenEncoder.hydro_secretbox_keygen
  str = "j4k3l25hj4l6hgb54jk6ghkj4g5k4h36jk45"
  ctx = "spectest"

  it "has a version number" do
    expect(::FFI::HydrogenEncoder::VERSION).not_to be nil
  end

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
  end

  describe "#hydro_secretbox_decrypt" do
    it "decrypts a string which matches the original" do
      encrypted = ::FFI::HydrogenEncoder.hydro_secretbox_encrypt(str, ctx, key)
      decrypted = ::FFI::HydrogenEncoder.hydro_secretbox_decrypt(encrypted, ctx, key)
      expect(decrypted).to eq(str)
    end
  end

  describe ::FFI::HydrogenEncoder::Secretbox do
    box = ::FFI::HydrogenEncoder::Secretbox.new(ctx, key)

    describe "#encrypt" do
      it "encrypts a string which does not match the original" do
        encrypted = box.encrypt(str)
        expect(encrypted).not_to eq(str)
      end
    end

    describe "#decrypt" do
      it "decrypts a string which matches the original" do
        encrypted = box.encrypt(str)
        decrypted = box.decrypt(encrypted)
        expect(decrypted).to eq(str)
      end
    end

    describe "#encrypt_encode" do
      it "encrypts/encodes a string which does not match the original" do
        encrypted = box.encrypt_encode(str)
        expect(encrypted).not_to eq(str)
      end
    end

    describe "#decode_decrypt" do
      it "decodes/decrypts a string which matches the original" do
        encrypted = box.encrypt_encode(str)
        decrypted = box.decode_decrypt(encrypted)
        expect(decrypted).to eq(str)
      end
    end
  end
end
