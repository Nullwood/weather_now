import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class AuthService {
  static const _usersKey = 'users';
  static const _currentUserKey = 'current_user';

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final login = prefs.getString(_currentUserKey);
    return login != null;
  }

  static Future<String?> currentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentUserKey);
  }

  static Future<bool> register(String login, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);
    final Map<String, String> users = usersJson != null
        ? Map<String, String>.from(jsonDecode(usersJson))
        : {};

    if (users.containsKey(login)) return false;

    final hashed = sha256.convert(utf8.encode(password)).toString();
    users[login] = hashed;

    await prefs.setString(_usersKey, jsonEncode(users));
    return true;
  }

  static Future<bool> login(String login, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);
    if (usersJson == null) return false;

    final Map<String, String> users = Map<String, String>.from(
      jsonDecode(usersJson),
    );
    final hashed = sha256.convert(utf8.encode(password)).toString();

    if (users[login] == hashed) {
      await prefs.setString(_currentUserKey, login);
      return true;
    }

    return false;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }
}
