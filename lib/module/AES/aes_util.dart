import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:convert';

class AESUtil {
  static String encryptText(String plainText, String key) {
    final keyBytes = encrypt.Key.fromUtf8(key.padRight(32).substring(0, 32));
    final iv = encrypt.IV.fromLength(16); // Fixed IV for simplicity (not recommended for production)
    final encrypter = encrypt.Encrypter(encrypt.AES(keyBytes, mode: encrypt.AESMode.cbc));

    final encrypted = encrypter.encrypt(plainText, iv: iv);
    // Encode both IV and encrypted text to Base64 and join them
    final result = base64.encode(iv.bytes) + ':' + encrypted.base64;
    return result;
  }

  static String decryptText(String combinedText, String key) {
    final keyBytes = encrypt.Key.fromUtf8(key.padRight(32).substring(0, 32));
    
    try {
      // Split the stored data to extract IV and ciphertext
      final parts = combinedText.split(':');
      if (parts.length != 2) throw 'Invalid data format';

      final iv = encrypt.IV.fromBase64(parts[0]);
      final encryptedText = parts[1];
      final encrypter = encrypt.Encrypter(encrypt.AES(keyBytes, mode: encrypt.AESMode.cbc));

      return encrypter.decrypt64(encryptedText, iv: iv);
    } catch (e) {
      return 'Decryption failed: $e';
    }
  }
}
