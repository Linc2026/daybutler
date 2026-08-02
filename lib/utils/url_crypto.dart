import 'dart:convert';

class UrlCrypto {
  static const _key = 'day_butler_matrix_key_2026';

  static String encrypt(String plain) {
    final bytes = utf8.encode(plain);
    final keyBytes = utf8.encode(_key);
    final encrypted = List<int>.generate(
      bytes.length,
      (i) => bytes[i] ^ keyBytes[i % keyBytes.length],
    );
    return base64Encode(encrypted);
  }

  static String decrypt(String encrypted) {
    final bytes = base64Decode(encrypted);
    final keyBytes = utf8.encode(_key);
    final decrypted = List<int>.generate(
      bytes.length,
      (i) => bytes[i] ^ keyBytes[i % keyBytes.length],
    );
    return utf8.decode(decrypted);
  }
}
