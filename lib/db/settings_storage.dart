import 'package:shared_preferences/shared_preferences.dart';

class SettingsStorage {
  static final SettingsStorage instance = SettingsStorage._internal();
  SharedPreferences? _prefs;

  SettingsStorage._internal();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Keys
  static const String keyClassName = 'className';
  static const String keyFontSize = 'fontSize';
  static const String keySortBy = 'sortBy';
  static const String keyIsDarkMode = 'isDarkMode';

  // Getters with defaults
  String get className => _prefs?.getString(keyClassName) ?? 'II M Tech CSE';
  double get fontSize => _prefs?.getDouble(keyFontSize) ?? 1.0;
  String get sortBy => _prefs?.getString(keySortBy) ?? 'regNo';
  bool get isDarkMode => _prefs?.getBool(keyIsDarkMode) ?? false;

  // Setters
  Future<void> setClassName(String name) async {
    await _prefs?.setString(keyClassName, name);
  }

  Future<void> setFontSize(double size) async {
    await _prefs?.setDouble(keyFontSize, size);
  }

  Future<void> setSortBy(String sort) async {
    await _prefs?.setString(keySortBy, sort);
  }

  Future<void> setDarkMode(bool dark) async {
    await _prefs?.setBool(keyIsDarkMode, dark);
  }

  // Reset to defaults
  Future<void> reset() async {
    await _prefs?.remove(keyClassName);
    await _prefs?.remove(keyFontSize);
    await _prefs?.remove(keySortBy);
    await _prefs?.remove(keyIsDarkMode);
  }
}
