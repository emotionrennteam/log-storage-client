/// Library that abstracts the storage for storing settings of different types ([int], [String], and [bool]).
library settings_storage;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences stores the app's settings in different locations
/// depending on the underlying OS:
/// * Linux: ~/.local/share/centrallogstorageclient/shared_preferences.json
SharedPreferences _sharedPreferences;

Future<SharedPreferences> _getStorageReference() async {
  try {
    if (_sharedPreferences == null) {
      _sharedPreferences = await SharedPreferences.getInstance();
    }
  } catch (e) {
    debugPrint(e.toString());
    // TODO: handle exception when preferences.json is malformed
  }
  return _sharedPreferences;
}

/// Persists a setting of type [String].
///
/// Returns true, if the settings was successfully persisted.
Future<bool> setStringSetting(String key, String value) async {
  final storageReference = await _getStorageReference();
  return storageReference.setString(key, value);
}

/// Retrieves a setting of type [String].
///
/// Returns the settings value. The return value defaults to [null],
/// if a setting with the given key doesn't exist.
Future<String> getStringSetting(String key) async {
  final storageReference = await _getStorageReference();
  return storageReference.getString(key);
}

/// Persists a setting of type [bool].
///
/// Returns true, if the settings was successfully persisted.
Future<bool> setBoolSetting(String key, bool value) async {
  final storageReference = await _getStorageReference();
  return await storageReference.setBool(key, value);
}

/// Retrieves a setting of type [bool].
///
/// Returns the settings value. The return value defaults to [null],
/// if a setting with the given key doesn't exist.
Future<bool> getBoolSetting(String key) async {
  final storageReference = await _getStorageReference();
  return storageReference.getBool(key);
}

/// Persists a setting of type [int].
///
/// Returns true, if the settings was successfully persisted.
Future<bool> setIntSetting(String key, int value) async {
  final storageReference = await _getStorageReference();
  return await storageReference.setInt(key, value);
}

/// Retrieves a setting of type [int].
///
/// Returns the settings value. The return value defaults to [null],
/// if a setting with the given key doesn't exist.
Future<int> getIntSetting(String key) async {
  final storageReference = await _getStorageReference();
  return storageReference.getInt(key);
}
