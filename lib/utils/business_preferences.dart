import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class BusinessPreferences {
  static SharedPreferences? _preferences;

  static const _keyBusinessId = 'businessId';
  static const _keyIsLogged = 'isLogged';
  static const _keyQtyLogged = 'qtyLogged';
  static const _keyEnableNotifications = 'enableNotifications';
  static const _keyBackgroundNotifications = 'backgroundNotifications';
  static const _keyVibrateNotifications = 'vibrateNotifications';
  static const _keySilentNotifications = 'silentNotifications';
  static const _updateNotification = 'updateNotification';
  static const _lastOpenNotification = 'lastOpenNotification';
  static const _lastClosedNotification = 'lastClosedNotification';
  static const _keyJWT = 'JWT';
  static const _keySessionId = 'sessionId';

  static Future init() async {
    _preferences = await SharedPreferences.getInstance();

    if(getBusinessToken() == null){
      await setBusinessToken('');
    }
    if(getSessionId() == null){
      await setSessionId('');
    }
    if(getBackgroundNotifications() == null){
      await setBackgroundNotifications(true);
    }
    if(getEnableNotifications() == null){
      await setEnableNotifications(true);
    }
    if(getVibrateNotifications() == null){
      await setVibrateNotifications(true);
    }
    if(getSilentNotifications() == null){
      await setSilentNotifications(false);
    }
    // if(_preferences.getInt(_keyQtyLogged) == null){
    //   await setQtyLogged(0);
    // }
    if(getIsLogged() == null){
      await setIsLogged(false);
    }
    if(getBusinessId() == null){
      await setBusinessId('');
    }
    if(getBusinessLastOpenNotification() == null){
      await _preferences!.setString(
          _lastOpenNotification,
          DateTime.now().subtract(const Duration(days: 99999)).toIso8601String()
      );
    }
    if(getBusinessLastClosedNotification() == null){
      await _preferences!.setString(
          _lastClosedNotification,
          DateTime.now().subtract(const Duration(days: 99998)).toIso8601String()
      );
    }

    // return _preferences = await SharedPreferences.getInstance();
    return _preferences;
  }

  static Future setBusinessId(String businessId) async {
    await _preferences!.setString(_keyBusinessId, businessId);
  }

  static String? getBusinessId() {
    return _preferences!.getString(_keyBusinessId);
  }

  static Future setSessionId(String sessionId) async {
    await _preferences!.setString(_keySessionId, sessionId);
  }

  static String? getSessionId() {
    return _preferences!/*?*/.getString(_keySessionId);
  }

  static Future setIsLogged(bool isLogged) async {
    await _preferences!.setBool(_keyIsLogged, isLogged);
  }

  static bool? getIsLogged() {
    return _preferences!.getBool(_keyIsLogged);
  }

  // static Future setQtyLogged(int qtyLogged) async {
  //   await _preferences.setInt(_keyQtyLogged, qtyLogged);
  // }

  // static Future<int> getQtyLogged() async {
  //   if(_preferences.getInt(_keyQtyLogged) == null){
  //     await setQtyLogged(0);
  //   }
  //
  //   return _preferences.getInt(_keyQtyLogged);
  // }

  static Future setEnableNotifications(bool enable) async {
    await _preferences!.setBool(_keyEnableNotifications, enable);
  }

  static bool? getEnableNotifications() {
    return _preferences!.getBool(_keyEnableNotifications);
  }

  static Future setBackgroundNotifications(bool enable) async {
    await _preferences!.setBool(_keyBackgroundNotifications, enable);
  }

  static bool? getBackgroundNotifications()  {
    return _preferences!.getBool(_keyBackgroundNotifications);
  }

  static Future setVibrateNotifications(bool enable) async {
    await _preferences!.setBool(_keyVibrateNotifications, enable);
  }

  static bool? getVibrateNotifications() {
    return _preferences!.getBool(_keyVibrateNotifications);
  }

  static Future setSilentNotifications(bool enable) async {
    await _preferences!.setBool(_keySilentNotifications, enable);
  }

  static bool? getSilentNotifications() {
    return _preferences!.getBool(_keySilentNotifications);
  }

  static Future setBusinessToken(String token) async {
    await _preferences!.setString(_keyJWT, token);
  }

  static String? getBusinessToken() {
    return _preferences!/*?*/.getString(_keyJWT);
  }

  static Future setBusinessLastUpdateNotification(DateTime dateTime) async {
    await _preferences!.setString(
        _updateNotification,
        dateTime.toIso8601String()
    );
  }

  static String? getBusinessLastUpdateNotification() {
    return _preferences!/*?*/.getString(_updateNotification);
  }

  static Future setBusinessLastOpenNotification() async {
    await _preferences!.setString(
        _lastOpenNotification,
        DateTime.now().toIso8601String()
    );
  }

  static String? getBusinessLastOpenNotification() {
    return _preferences!/*?*/.getString(_lastOpenNotification);
  }

  static Future setBusinessLastClosedNotification() async {
    await _preferences!.setString(
        _lastClosedNotification,
        DateTime.now().toIso8601String()
    );
  }

  static String? getBusinessLastClosedNotification() {
    return _preferences!/*?*/.getString(_lastClosedNotification);
  }
// static Future setUser(User user) async {
  //   final json = jsonEncode(user.toJson());
  //   final idUser = user.id;
  //
  //   await _preferences.setString(idUser.toString(), json);
  // }
  //
  // static User getUser(String idUser) {
  //   final json = _preferences.getString(idUser);
  //
  //   return User.fromJson(jsonDecode(json));
  // }
  //
  // static Future addUsers(User user) async {
  //   final idUsers = _preferences.getStringList(_keyUsers) ?? <String>[];
  //   final newIdUsers = List.of(idUsers)..add(user.id.toString());
  //
  //   await _preferences.setStringList(_keyUsers, newIdUsers);
  // }
  //
  // static List<User> getUsers() {
  //   final idUsers = _preferences.getStringList(_keyUsers);
  //
  //   if (idUsers == null) {
  //     return <User>[];
  //   } else {
  //     return idUsers.map<User>(getUser).toList();
  //   }
  // }
}
