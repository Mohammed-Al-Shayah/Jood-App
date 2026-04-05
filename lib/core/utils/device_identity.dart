import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

class DeviceIdentity {
  const DeviceIdentity._();

  static const String _storageKey = 'jood_device_id';

  static Future<String> getOrCreateId() async {
    final preferences = await SharedPreferences.getInstance();
    final existing = preferences.getString(_storageKey)?.trim() ?? '';
    if (existing.isNotEmpty) {
      return existing;
    }

    final generated = _generateId();
    await preferences.setString(_storageKey, generated);
    return generated;
  }

  static String _generateId() {
    final random = Random.secure();
    final buffer = StringBuffer(
      'jood-${DateTime.now().microsecondsSinceEpoch.toRadixString(16)}-',
    );

    for (var index = 0; index < 16; index++) {
      buffer.write(random.nextInt(256).toRadixString(16).padLeft(2, '0'));
    }

    return buffer.toString();
  }
}
