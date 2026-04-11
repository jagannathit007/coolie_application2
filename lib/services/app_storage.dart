import 'dart:convert';

import 'package:get_storage/get_storage.dart';

class AppStorage {
  static final GetStorage _storage = GetStorage();

  static Future<void> write(String key, dynamic value) async {
    if (value == null) {
      await _storage.remove(key);
    } else {
      final encodedValue = jsonEncode(value);
      await _storage.write(key, encodedValue);
    }
  }

  static T? read<T>(String key) {
    final encodedValue = _storage.read(key);
    if (encodedValue == null) return null;
    return jsonDecode(encodedValue) as T;
  }

  static Future<void> clearAll() async {
    await _storage.erase();
  }

  static Future<void> remove(String key) async {
    await _storage.remove(key);
  }

  static bool hasData(String key) {
    return _storage.hasData(key);
  }
}
