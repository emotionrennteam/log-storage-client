library settings;

import 'package:log_storage_client/models/storage_connection_credentials.dart';
import 'package:log_storage_client/utils/settings_storage.dart';
import 'package:flutter/foundation.dart';

const String _AUTO_UPLOAD_ENABLED = 'AUTO_UPLOAD_ENABLED';
const String _LOG_FILE_DIRECTORY_PATH = 'LOG_FILE_DIRECTORY_PATH';
const String _MINIO_ACCESS_KEY = 'MINIO_ACCESS_KEY';
const String _MINIO_BUCKET = 'MINIO_BUCKET';
const String _MINIO_ENDPOINT = 'MINIO_ENDPOINT';
const String _MINIO_PORT = 'MINIO_PORT';
const String _MINIO_REGION = 'MINIO_REGION';
const String _MINIO_SECRET_KEY = 'MINIO_SECRET_KEY';
const String _MINIO_TLS_ENABLED = 'MINIO_TLS_ENABLED';

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
      setMinioEndpoint(endpoint),
      setMinioPort(portAsInt),
      setMinioRegion(region),
      setMinioBucket(bucket),
      setMinioAccessKey(accessKey),
      setMinioSecretKey(secretKey),
      setMinioTlsEnabled(tlsEnabled),
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
  final endpoint = await getMinioEndpoint();
  final port = await getMinioPort();
  final region = await getMinioRegion();
  final bucket = await getMinioBucket();
  final accessKey = await getMinioAccessKey();
  final secretKey = await getMinioSecretKey();
  final tlsEnabled = await getMinioTlsEnabled();
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

Future<String> getMinioRegion() async {
  return await getStringSetting(_MINIO_REGION);
}

Future<bool> setMinioRegion(String region) async {
  return await setStringSetting(_MINIO_REGION, region);
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

Future<bool> setAutoUploadEnabled(bool enabled) async {
  return await setBoolSetting(_AUTO_UPLOAD_ENABLED, enabled);
}

Future<bool> getAutoUploadEnabled() async {
  return await getBoolSetting(_AUTO_UPLOAD_ENABLED);
}
