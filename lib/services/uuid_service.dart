import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class UUIDService {
  static const _key = 'device_uuid';
  static final _uuid = Uuid();

  static Future<String> getOrCreateUUID() async {
    final prefs = await SharedPreferences.getInstance();
    String? uuid = prefs.getString(_key);

    if (uuid == null) {
      uuid = _uuid.v4();
      await prefs.setString(_key, uuid);
    }

    return uuid;
  }

  static Future<String?> getSavedUUID() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }
}
