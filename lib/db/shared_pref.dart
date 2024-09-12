import 'package:shared_preferences/shared_preferences.dart';

class MySharedPrefference {
  static SharedPreferences? _preferences;
  static const String userTypeKey = 'usertype';
  static const String emailKey = 'useremail';

  // Initialize SharedPreferences instance
  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // Save user type to preferences
  static Future<void> saveUserType(String type) async {
    await _preferences!.setString(userTypeKey, type);
  }

  // Retrieve user type from preferences
  static Future<String?> getUserType() async {
    return _preferences!.getString(userTypeKey);
  }

  // Save user's email to preferences after login
  static Future<void> saveUserEmail(String email) async {
    await _preferences!.setString(emailKey, email);
  }

  // Retrieve the stored email for future authentication
  static Future<String?> getUserEmail() async {
    return _preferences!.getString(emailKey);
  }

  // Clear the stored email (for logout)
  static Future<void> clearUserEmail() async {
    await _preferences!.remove(emailKey);
  }
}
