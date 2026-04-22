import 'package:shared_preferences/shared_preferences.dart';

enum CookingSkill { novice, intermediate, master }

CookingSkill _skillFromId(String? id) {
  switch (id) {
    case 'novice':
      return CookingSkill.novice;
    case 'master':
      return CookingSkill.master;
    default:
      return CookingSkill.intermediate;
  }
}

String skillId(CookingSkill skill) => skill.name;

class ProfilePreferences {
  ProfilePreferences._(this._prefs);

  static const _keyNotifications = 'profile.notifications_enabled';
  static const _keySkill = 'profile.cooking_skill';

  final SharedPreferences _prefs;

  static Future<ProfilePreferences> load() async {
    final p = await SharedPreferences.getInstance();
    return ProfilePreferences._(p);
  }

  bool get notificationsEnabled => _prefs.getBool(_keyNotifications) ?? true;
  Future<void> setNotificationsEnabled(bool value) =>
      _prefs.setBool(_keyNotifications, value);

  CookingSkill get cookingSkill => _skillFromId(_prefs.getString(_keySkill));
  Future<void> setCookingSkill(CookingSkill skill) =>
      _prefs.setString(_keySkill, skillId(skill));
}
