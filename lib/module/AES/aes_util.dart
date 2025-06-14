import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:convert';
import 'dart:typed_data';

class AESUtil {
  /// Encrypts the text using AES CBC with a securely generated IV
  static String encryptText(String plainText, String key) {
    final keyBytes = encrypt.Key.fromUtf8(key.padRight(32).substring(0, 32));
    final iv = encrypt.IV.fromSecureRandom(16); // Secure random IV
    final encrypter = encrypt.Encrypter(
      encrypt.AES(keyBytes, mode: encrypt.AESMode.cbc),
    );

    final encrypted = encrypter.encrypt(plainText, iv: iv);

    // Encode both IV and encrypted text to Base64 and join them with a colon
    final result = '${base64.encode(iv.bytes)}:${encrypted.base64}';
    return result;
  }

  /// Decrypts the text assuming IV and ciphertext are joined by a colon
  static String decryptText(String combinedText, String key) {
    final keyBytes = encrypt.Key.fromUtf8(key.padRight(32).substring(0, 32));

    try {
      final parts = combinedText.split(':');
      if (parts.length != 2) throw 'Invalid data format';

      final ivBytes = base64.decode(parts[0]);
      final iv = encrypt.IV(Uint8List.fromList(ivBytes));
      final encryptedText = parts[1];

      final encrypter = encrypt.Encrypter(
        encrypt.AES(keyBytes, mode: encrypt.AESMode.cbc),
      );

      return encrypter.decrypt64(encryptedText, iv: iv);
    } catch (e) {
      return 'Decryption failed: $e';
    }
  }
}
