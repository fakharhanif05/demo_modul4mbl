// ============ shared_prefs_service.dart ============
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Theme
  static bool get isDarkMode => _prefs?.getBool('isDarkMode') ?? false;
  
  static Future<void> setDarkMode(bool value) async {
    await _prefs?.setBool('isDarkMode', value);
  }

  // Guest Mode
  static bool get isGuestMode => _prefs?.getBool('isGuestMode') ?? false;
  
  static Future<void> setGuestMode(bool value) async {
    await _prefs?.setBool('isGuestMode', value);
  }

  // Last Sync Time
  static DateTime? get lastSyncTime {
    final timestamp = _prefs?.getString('lastSyncTime');
    return timestamp != null ? DateTime.parse(timestamp) : null;
  }
  
  static Future<void> setLastSyncTime(DateTime time) async {
    await _prefs?.setString('lastSyncTime', time.toIso8601String());
  }

  // Clear all
  static Future<void> clear() async {
    await _prefs?.clear();
  }
}