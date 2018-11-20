#include <stdio.h>

#include "libhydrogen/hydrogen.c"
#include "stringencoders/src/modp_b64.c"

int main(int argc, char **argv) {
  (void)argc;
  (void)argv;

  if (hydro_init() != 0) {
    abort();
  }

  char *context = "examples";
  char *text = "testing 3 2 1!";

  size_t msgsize = hydro_secretbox_HEADERBYTES + strlen(text);

  uint8_t key[hydro_secretbox_KEYBYTES];
  uint8_t ciphertext[hydro_secretbox_HEADERBYTES + strlen(text)];

  hydro_secretbox_keygen(key);
  hydro_secretbox_encrypt(ciphertext, text, strlen(text), 0, context, key);

  char decrypted[strlen(text)];
  if (hydro_secretbox_decrypt(decrypted, ciphertext, msgsize, 0, context,
                              key) != 0) {
    printf("error");
  }

  printf("decrypted: %s\n", decrypted);

  char *str = "testing 1 2 3!";
  printf("encoded size is %d\n", modp_b64_encode_len(strlen(str)));
  char *encoded[modp_b64_encode_len(strlen(str))];
  memset(encoded, 0, modp_b64_encode_len(strlen(str)));

  modp_b64_encode(encoded, str, strlen(str));
  printf("%s\n", encoded);

  char *decoded[strlen(encoded)];
  memset(decoded, 0, modp_b64_encode_len(strlen(str)));

  size_t s = modp_b64_decode(decoded, encoded, strlen(encoded));
  printf("%zu, %s\n", s, decoded);

  return 0;
}
