import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  // Guardar un valor en SharedPreferences
  static Future<void> saveToPrefs(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();

    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    } else {
      throw Exception("Unsupported value type for SharedPreferences");
    }
  }

  // Leer un valor de SharedPreferences
  static Future<T?> readFromPrefs<T>(String key) async {
    final prefs = await SharedPreferences.getInstance();

    if (T == bool) return prefs.getBool(key) as T?;
    if (T == int) return prefs.getInt(key) as T?;
    if (T == double) return prefs.getDouble(key) as T?;
    if (T == String) return prefs.getString(key) as T?;

    throw Exception("Unsupported value type for SharedPreferences");
  }

  // Eliminar un valor de SharedPreferences
  static Future<void> deleteFromPrefs(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  static Future<void> deleteAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
