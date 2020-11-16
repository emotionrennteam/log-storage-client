library app_settings;

import 'dart:convert';

import 'package:log_storage_client/models/storage_connection_credentials.dart';
import 'package:log_storage_client/models/upload_profile.dart';
import 'package:log_storage_client/utils/settings_storage.dart';
import 'package:flutter/foundation.dart';

const String _AUTO_UPLOAD_ENABLED = 'AUTO_UPLOAD_ENABLED';
const String _LOG_FILE_DIRECTORY_PATH = 'LOG_FILE_DIRECTORY_PATH';
const String _STORAGE_ACCESS_KEY = 'STORAGE_ACCESS_KEY';
const String _STORAGE_BUCKET = 'STORAGE_BUCKET';
const String _STORAGE_ENDPOINT = 'STORAGE_ENDPOINT';
const String _STORAGE_PORT = 'STORAGE_PORT';
const String _STORAGE_REGION = 'STORAGE_REGION';
const String _STORAGE_SECRET_KEY = 'STORAGE_SECRET_KEY';
const String _STORAGE_TLS_ENABLED = 'STORAGE_TLS_ENABLED';
const String _UPLOAD_PROFILES = 'UPLOAD_PROFILES';

Future<bool> saveAllSettings(
  String endpoint,
  String port,
  String region,
  String bucket,
  String accessKey,
  String secretKey,
  bool tlsEnabled,
  String logFileDirectoryPath,
  bool autoUploadEnabled,
) async {
  int portAsInt;
  try {
    portAsInt = port.isNotEmpty ? int.parse(port) : null;
  } catch (_) {
    return false;
  }
  try {
    List<bool> responses = await Future.wait([
      setStorageEndpoint(endpoint),
      setStoragePort(portAsInt),
      setStorageRegion(region),
      setStorageBucket(bucket),
      setStorageAccessKey(accessKey),
      setStorageSecretKey(secretKey),
      setStorageTlsEnabled(tlsEnabled),
      setLogFileDirectoryPath(logFileDirectoryPath),
      setAutoUploadEnabled(autoUploadEnabled),
    ]);
    return !responses.contains(false);
  } catch (e) {
    debugPrint('Failed to save settings. Exception: $e');
    return false;
  }
}

Future<StorageConnectionCredentials> getStorageConnectionCredentials() async {
  final endpoint = await getStorageEndpoint();
  final port = await getStoragePort();
  final region = await getStorageRegion();
  final bucket = await getStorageBucket();
  final accessKey = await getStorageAccessKey();
  final secretKey = await getStorageSecretKey();
  final tlsEnabled = await getStorageTlsEnabled();
  return new StorageConnectionCredentials(
    endpoint,
    port,
    region,
    bucket,
    accessKey,
    secretKey,
    tlsEnabled,
  );
}

Future<bool> setStorageBucket(String bucket) async {
  return await setStringSetting(_STORAGE_BUCKET, bucket);
}

Future<String> getStorageBucket() async {
  return await getStringSetting(_STORAGE_BUCKET);
}

Future<bool> setStorageEndpoint(String endpoint) async {
  return await setStringSetting(_STORAGE_ENDPOINT, endpoint);
}

Future<String> getStorageEndpoint() async {
  return await getStringSetting(_STORAGE_ENDPOINT);
}

Future<bool> setStoragePort(int port) async {
  return await setIntSetting(_STORAGE_PORT, port);
}

Future<int> getStoragePort() async {
  return await getIntSetting(_STORAGE_PORT);
}

Future<bool> setStorageAccessKey(String accessKey) async {
  return await setStringSetting(_STORAGE_ACCESS_KEY, accessKey);
}

Future<String> getStorageAccessKey() async {
  return await getStringSetting(_STORAGE_ACCESS_KEY);
}

Future<bool> setStorageSecretKey(String secretKey) async {
  return await setStringSetting(_STORAGE_SECRET_KEY, secretKey);
}

Future<String> getStorageRegion() async {
  return await getStringSetting(_STORAGE_REGION);
}

Future<bool> setStorageRegion(String region) async {
  return await setStringSetting(_STORAGE_REGION, region);
}

Future<String> getStorageSecretKey() async {
  return await getStringSetting(_STORAGE_SECRET_KEY);
}

Future<bool> setStorageTlsEnabled(bool enabled) async {
  return await setBoolSetting(_STORAGE_TLS_ENABLED, enabled);
}

Future<bool> getStorageTlsEnabled() async {
  return await getBoolSetting(_STORAGE_TLS_ENABLED);
}

Future<bool> setLogFileDirectoryPath(String logFileDirectoryPath) async {
  return await setStringSetting(_LOG_FILE_DIRECTORY_PATH, logFileDirectoryPath);
}

Future<String> getLogFileDirectoryPath() async {
  return await getStringSetting(_LOG_FILE_DIRECTORY_PATH);
}

Future<bool> setAutoUploadEnabled(bool enabled) async {
  return await setBoolSetting(_AUTO_UPLOAD_ENABLED, enabled);
}

Future<bool> getAutoUploadEnabled() async {
  return await getBoolSetting(_AUTO_UPLOAD_ENABLED);
}

Future<List<UploadProfile>> getUploadProfiles() async {
  final profilesJson = await getStringSetting(_UPLOAD_PROFILES);
  if (profilesJson == null || profilesJson.isEmpty) {
    return List();
  }
  final Iterable iterable = json.decode(profilesJson);
  return List<UploadProfile>.from(
    iterable.map((e) => UploadProfile.fromJson(e)),
  ).toList();
}

Future<bool> setUploadProfiles(List<UploadProfile> uploadProfiles) async {
  final profilesJson = json.encode(uploadProfiles);
  return await setStringSetting(_UPLOAD_PROFILES, profilesJson);
}

Future<UploadProfile> getEnabledUploadProfile() async {
  final profiles = await getUploadProfiles();
  return profiles.where((element) => element.enabled).first;
}
