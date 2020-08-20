/// Library that abstracts the storage for storing settings of different types ([int], [String], and [bool]).
///
/// The current implementation doesn't use the famous library "shared_preferences"
/// because of its incompatibility with Microsoft Windows. Instead, we have to rely on the
/// library "cross_local_storage" until the pull request https://github.com/flutter/plugins/pull/2631
/// has been merged. This plugin stores settings in the local JSON file "preferences.json".
library settings_storage;

import 'package:cross_local_storage/cross_local_storage.dart';

LocalStorageInterface _localStorageInterface;

Future<LocalStorageInterface> _getStorageReference() async {
  if (_localStorageInterface == null) {
    _localStorageInterface = await LocalStorage.getInstance();
  }
  return _localStorageInterface;
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
