#include <stdio.h>

#include "libhydrogen/hydrogen.c"
#include "stringencoders/src/modp_b64.c"

/**
 * Encrypts and encodes a message using hydro_secretbox_encrypt and
 * modp_b64_encode functions. Size of the dest parameter should be:
 *
 *     modp_b64_encode_len(size of message + hydro_secretbox_HEADERBYTES);
 *
 *
 * @example
 *
 *     const char* message = "My secret message";
 *     const char* context = "examples";
 *     const uint8_t key[hydro_secretbox_KEYBYTES];
 *     hydro_secretbox_keygen(key);
 *
 *     int max = modp_b64_encode_len(strlen(message) + hydro_secretbox_HEADERBYTES);
 *     char* dest[max];
 *     size_t size = encrypt_encode(dest, message, strlen(message), 0, context, key);
 *
 *
 * @param dest stores the output string
 * @param message is the original message to encrypt and encode
 * @param message_len is the size of the message parameter
 * @param message_id XXX
 * @param context XXX
 * @param key XXX
 * @return size of the encoded string
 */
size_t encrypt_encode(char* dest, const char* message, size_t message_len,
                      uint64_t message_id,
                      const char context[hydro_secretbox_CONTEXTBYTES],
                      const uint8_t key[hydro_secretbox_KEYBYTES]) {
  int cipher_len = message_len + hydro_secretbox_HEADERBYTES;
  uint8_t cipher[cipher_len];
  int status = hydro_secretbox_encrypt(cipher, message, message_len, message_id,
                                       context, key);

  if (status != 0) {
    return 0;
  }

  return modp_b64_encode(dest, cipher, cipher_len);
}

/**
 * Decodes and decrypts a message using modp_b64_decode and
 * hydro_secretbox_decrypt functions. Since the estimated decoded size is not
 * always accurate, it is safest to allocate a little more than required and
 * then clean up the result using the real size, which is returned by this
 * function:
 *
 *     int max = modp_b64_decode_len(size of message);
 *     size_t real = decode_decrypt(...);
 *
 * @example
 *
 *     // Assuming a key and context already exist, as well as a message, which
 *     // is the encoded and encoded message.
 *     int max = modp_b64_decode_len(strlen(message));
 *     char* dest[max];
 *     size_t size = decode_decrypt(dest, message, strlen(message), 0, context, key);
 *
 *
 * @param dest stores the output string
 * @param message is the message to decode and decrypt
 * @param message_len is the size of the message parameter
 * @param message_id XXX
 * @param context XXX
 * @param key XXX
 * @return size of the decrypted string
 */
size_t decode_decrypt(char* dest, const void* message, size_t message_len,
                      uint64_t message_id,
                      const char context[hydro_secretbox_CONTEXTBYTES],
                      const uint8_t key[hydro_secretbox_KEYBYTES]) {
  int max_decoded_len = modp_b64_decode_len(message_len);
  char* decoded[max_decoded_len];
  int decoded_len = modp_b64_decode(decoded, message, message_len);
  int status = hydro_secretbox_decrypt(dest, decoded, decoded_len, message_id,
                                       context, key);

  if (status != 0) {
    return 0;
  }

  return decoded_len - hydro_secretbox_HEADERBYTES;
}

int main(int argc, char** argv) {
  (void)argc;
  (void)argv;

  const char* message =
      "The C Programming Language (sometimes termed K&R, after its authors' "
      "initials) is a computer programming book written by Brian Kernighan and "
      "Dennis Ritchie, the latter of whom originally designed and implemented "
      "the language, as well as co-designed the Unix operating system with "
      "which development of the language was closely intertwined. The book was "
      "central to the development and popularization of the C programming "
      "language and is still widely read and used today. Because the book was "
      "co-authored by the original language designer, and because the first "
      "edition of the book served for many years as the de facto standard for "
      "the language, the book was regarded by many to be the authoritative "
      "reference on C.";

  const char* context = "examples";
  const uint8_t key[hydro_secretbox_KEYBYTES];
  hydro_secretbox_keygen(key);

  int encrypt_encode_len =
      modp_b64_encode_len(strlen(message) + hydro_secretbox_HEADERBYTES);
  char* encoded_ptr[encrypt_encode_len];
  size_t size =
      encrypt_encode(encoded_ptr, message, strlen(message), 0, context, key);

  int max_size = modp_b64_decode_len(strlen(encoded_ptr));
  char* result[max_size];
  int real_size =
      decode_decrypt(result, encoded_ptr, strlen(encoded_ptr), 0, context, key);
  printf("max_size = %d\n", max_size);
  printf("size = %d\n", real_size);
  printf("result = %s\n", result);
}
