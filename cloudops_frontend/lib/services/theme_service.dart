import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ThemeService {
  static final FlutterSecureStorage _secure = const FlutterSecureStorage();
  static final ValueNotifier<bool> darkMode = ValueNotifier<bool>(true);
  static const String _key = 'pref_dark_mode';

  /// Initialize theme preference from secure storage. Call once before runApp.
  static Future<void> initTheme() async {
    final s = await _secure.read(key: _key);
    if (s == null) {
      darkMode.value = true;
    } else {
      darkMode.value = s == '1';
    }
  }

  /// Persist and apply the chosen mode.
  static Future<void> setDark(bool isDark) async {
    await _secure.write(key: _key, value: isDark ? '1' : '0');
    darkMode.value = isDark;
  }
}
