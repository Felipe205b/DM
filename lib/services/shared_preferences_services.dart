import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/models/book.dart';
import 'preferences_keys.dart';

class SharedPreferencesService {
  final SharedPreferences _prefs;

  SharedPreferencesService._(this._prefs);

  static SharedPreferencesService? _instance;

  static Future<SharedPreferencesService> getInstance() async {
    if (_instance != null) return _instance!;

    final prefs = await SharedPreferences.getInstance();
    _instance = SharedPreferencesService._(prefs);
    return _instance!;
  }

  static Future<void> setMarketingConsent(bool consent) async {
    if (_instance == null) {
      await getInstance();
    }
    await _instance!._prefs.setBool(PreferencesKeys.marketingConsent, consent);
  }

  static Future<bool> getMarketingConsent() async {
    if (_instance == null) {
      await getInstance();
    }
    return _instance!._prefs.getBool(PreferencesKeys.marketingConsent) ?? false;
  }

  static Future<void> setPrivacyPolicyAllRead(bool read) async {
    if (_instance == null) {
      await getInstance();
    }
    await _instance!._prefs.setBool(PreferencesKeys.privacyPolicyAllRead, read);
  }

  static Future<bool> getPrivacyPolicyAllRead() async {
    if (_instance == null) {
      await getInstance();
    }
    return _instance!._prefs.getBool(PreferencesKeys.privacyPolicyAllRead) ??
        false;
  }

  static Future<void> revokeMarketingConsent() async {
    if (_instance == null) {
      await getInstance();
    }
    await _instance!._prefs.remove(PreferencesKeys.marketingConsent);
  }

  static Future<void> setTermsOfUseReadStatus(bool read) async {
    if (_instance == null) {
      await getInstance();
    }
    await _instance!._prefs.setBool(PreferencesKeys.termsOfUseAllRead, read);
  }

  static Future<bool> getTermsOfUseReadStatus() async {
    if (_instance == null) {
      await getInstance();
    }
    return _instance!._prefs.getBool(PreferencesKeys.termsOfUseAllRead) ??
        false;
  }

  static Future<void> removeAll() async {
    if (_instance == null) {
      await getInstance();
    }
    await _instance!._prefs.clear();
  }

  static Future<void> setUserName(String name) async {
    if (_instance == null) {
      await getInstance();
    }
    await _instance!._prefs.setString(PreferencesKeys.userName, name);
  }

  static Future<String?> getUserName() async {
    if (_instance == null) {
      await getInstance();
    }
    return _instance!._prefs.getString(PreferencesKeys.userName);
  }

  static Future<void> setUserEmail(String email) async {
    if (_instance == null) {
      await getInstance();
    }
    await _instance!._prefs.setString(PreferencesKeys.userEmail, email);
  }

  static Future<String?> getUserEmail() async {
    if (_instance == null) {
      await getInstance();
    }
    return _instance!._prefs.getString(PreferencesKeys.userEmail);
  }

  static Future<void> setProfileImagePath(String path) async {
    if (_instance == null) {
      await getInstance();
    }
    await _instance!._prefs.setString(PreferencesKeys.profileImagePath, path);
  }

  static Future<String?> getProfileImagePath() async {
    if (_instance == null) {
      await getInstance();
    }
    return _instance!._prefs.getString(PreferencesKeys.profileImagePath);
  }

  static Future<void> saveBooks(List<Book> books) async {
    if (_instance == null) {
      await getInstance();
    }
    final booksMap = books.map((book) => book.toMap()).toList();
    await _instance!._prefs.setString(PreferencesKeys.books, jsonEncode(booksMap));
  }

  static Future<List<Book>> getBooks() async {
    if (_instance == null) {
      await getInstance();
    }
    final booksString = _instance!._prefs.getString(PreferencesKeys.books);
    if (booksString == null) {
      return [];
    }
    final booksMap = jsonDecode(booksString) as List;
    return booksMap.map((map) => Book.fromMap(map)).toList();
  }

  static Future<void> setTutorialStep(int step) async {
    if (_instance == null) {
      await getInstance();
    }
    await _instance!._prefs.setInt(PreferencesKeys.tutorialStep, step);
  }

  static Future<int> getTutorialStep() async {
    if (_instance == null) {
      await getInstance();
    }
    return _instance!._prefs.getInt(PreferencesKeys.tutorialStep) ?? 1;
  }

  static Future<void> addToQueue(String action, Map<String, dynamic> data) async {
    if (_instance == null) {
      await getInstance();
    }
    final queue = await getQueue();
    queue.add({'action': action, 'data': data});
    await _instance!._prefs.setString('queue', jsonEncode(queue));
  }

  static Future<List<Map<String, dynamic>>> getQueue() async {
    if (_instance == null) {
      await getInstance();
    }
    final queueString = _instance!._prefs.getString('queue');
    if (queueString == null) {
      return [];
    }
    return (jsonDecode(queueString) as List)
        .map((item) => item as Map<String, dynamic>)
        .toList();
  }

  static Future<void> clearQueue() async {
    if (_instance == null) {
      await getInstance();
    }
    await _instance!._prefs.remove('queue');
  }

  static Future<void> setThemeMode(String mode) async {
    if (_instance == null) {
      await getInstance();
    }
    await _instance!._prefs.setString(PreferencesKeys.themeMode, mode);
  }

  static Future<String> getThemeMode() async {
    if (_instance == null) {
      await getInstance();
    }
    return _instance!._prefs.getString(PreferencesKeys.themeMode) ?? 'system';
  }
}
