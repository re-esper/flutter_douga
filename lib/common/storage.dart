import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  static SharedPreferences _preferences;
  static initialize() async {
    _preferences = await SharedPreferences.getInstance();    
  }

  static Future<bool> putObject(String key, Object value) {
    if (_preferences == null) return null;
    return _preferences.setString(key, value == null ? "" : json.encode(value));
  }

  static Map getObject(String key) {
    if (_preferences == null) return null;
    String _data = _preferences.getString(key);
    return (_data == null || _data.isEmpty) ? null : json.decode(_data);
  }

  static Future<bool> putObjectList(String key, List<Object> list) {
    if (_preferences == null) return null;
    List<String> _dataList = list?.map((value) {
      return json.encode(value);
    })?.toList();
    return _preferences.setStringList(key, _dataList);
  }

  static List<Map> getObjectList(String key) {
    if (_preferences == null) return null;
    List<String> dataLis = _preferences.getStringList(key);
    return dataLis?.map((value) {
      Map _dataMap = json.decode(value);
      return _dataMap;
    })?.toList();
  }

  static String getString(String key, {String defvalue: ''}) {
    if (_preferences == null) return defvalue;
    return _preferences.getString(key) ?? defvalue;
  }

  static Future<bool> putString(String key, String value) {
    if (_preferences == null) return null;
    return _preferences.setString(key, value);
  }

  static bool getBool(String key, {bool defvalue: false}) {
    if (_preferences == null) return defvalue;
    return _preferences.getBool(key) ?? defvalue;
  }

  static Future<bool> putBool(String key, bool value) {
    if (_preferences == null) return null;
    return _preferences.setBool(key, value);
  }

  static int getInt(String key, {int defvalue: 0}) {
    if (_preferences == null) return defvalue;
    return _preferences.getInt(key) ?? defvalue;
  }

  static Future<bool> putInt(String key, int value) {
    if (_preferences == null) return null;
    return _preferences.setInt(key, value);
  }

  static double getDouble(String key, {double defvalue: 0.0}) {
    if (_preferences == null) return defvalue;
    return _preferences.getDouble(key) ?? defvalue;
  }

  static Future<bool> putDouble(String key, double value) {
    if (_preferences == null) return null;
    return _preferences.setDouble(key, value);
  }

  static List<String> getStringList(String key) {
    if (_preferences == null) return new List<String>();
    return _preferences.getStringList(key) ?? new List<String>();
  }

  static Future<bool> putStringList(String key, List<String> value) {
    if (_preferences == null) return null;
    return _preferences.setStringList(key, value);
  }

  static bool hasKey(String key) {
    if (_preferences == null) return null;
    return _preferences.getKeys().contains(key);
  }

  static Set<String> getKeys() {
    if (_preferences == null) return null;
    return _preferences.getKeys();
  }

  static Future<bool> remove(String key) {
    if (_preferences == null) return null;    
    return _preferences.remove(key);
  }

  static Future<bool> clear() {
    if (_preferences == null) return null;
    return _preferences.clear();
  }

  static bool isInitialized() {
    return _preferences != null;
  }
}
