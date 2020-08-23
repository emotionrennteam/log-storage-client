library settings;

import 'package:emotion/utils/settings_storage.dart';
import 'package:flutter/foundation.dart';

const String _LOG_FILE_DIRECTORY_PATH = 'LOG_FILE_DIRECTORY_PATH';
const String _MINIO_ACCESS_KEY = 'MINIO_ACCESS_KEY';
const String _MINIO_BUCKET = 'MINIO_BUCKET';
const String _MINIO_ENDPOINT = 'MINIO_ENDPOINT';
const String _MINIO_PORT = 'MINIO_PORT';
const String _MINIO_SECRET_KEY = 'MINIO_SECRET_KEY';
const String _MINIO_TLS_ENABLED = 'MINIO_TLS_ENABLED';

Future<bool> saveAllSettings(String endpoint, String port, String accessKey,
    String secretKey, String bucket, bool tlsEnabled, String logFileDirectoryPath) async {
  int portAsInt;
  try {
    portAsInt = int.parse(port);
  } catch (_) {
    return false;
  }
  try {
    List<bool> responses = await Future.wait([
      setMinioEndpoint(endpoint),
      setMinioPort(portAsInt),
      setMinioAccessKey(accessKey),
      setMinioSecretKey(secretKey),
      setMinioBucket(bucket),
      setMinioTlsEnabled(tlsEnabled),
      setLogFileDirectoryPath(logFileDirectoryPath),
    ]);
    return !responses.contains(false);
  } catch (e) {
    debugPrint(e.toString());
    return false;
  }
}

Future<bool> setMinioBucket(String bucket) async {
  return await setStringSetting(_MINIO_BUCKET, bucket);
}

Future<String> getMinioBucket() async {
  return await getStringSetting(_MINIO_BUCKET);
}

Future<bool> setMinioEndpoint(String endpoint) async {
  return await setStringSetting(_MINIO_ENDPOINT, endpoint);
}

Future<String> getMinioEndpoint() async {
  return await getStringSetting(_MINIO_ENDPOINT);
}

Future<bool> setMinioPort(int port) async {
  return await setIntSetting(_MINIO_PORT, port);
}

Future<int> getMinioPort() async {
  return await getIntSetting(_MINIO_PORT);
}

Future<bool> setMinioAccessKey(String accessKey) async {
  return await setStringSetting(_MINIO_ACCESS_KEY, accessKey);
}

Future<String> getMinioAccessKey() async {
  return await getStringSetting(_MINIO_ACCESS_KEY);
}

Future<bool> setMinioSecretKey(String secretKey) async {
  return await setStringSetting(_MINIO_SECRET_KEY, secretKey);
}

Future<String> getMinioSecretKey() async {
  return await getStringSetting(_MINIO_SECRET_KEY);
}

Future<bool> setMinioTlsEnabled(bool enabled) async {
  return await setBoolSetting(_MINIO_TLS_ENABLED, enabled);
}

Future<bool> getMinioTlsEnabled() async {
  return await getBoolSetting(_MINIO_TLS_ENABLED);
}

Future<bool> setLogFileDirectoryPath(String logFileDirectoryPath) async {
  return await setStringSetting(_LOG_FILE_DIRECTORY_PATH, logFileDirectoryPath);
}

Future<String> getLogFileDirectoryPath() async {
  return await getStringSetting(_LOG_FILE_DIRECTORY_PATH);
}
