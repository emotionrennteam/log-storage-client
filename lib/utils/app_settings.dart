library settings;

import 'package:emotion/utils/settings_storage.dart';

const String _MINIO_ENDPOINT = 'MINIO_ENDPOINT';
const String _MINIO_PORT = 'MINIO_PORT';
const String _MINIO_ACCESS_KEY = 'MINIO_ACCESS_KEY';
const String _MINIOsECRET_KEY = 'MINIO_SECRET_KEY';
const String _MINIO_TLS_ENABLED = 'MINIO_TLS_ENABLED';

Future<bool> saveAllSettings(String endpoint, String port, String accessKey,
    String secretKey, bool tlsEnabled) async {
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
      setMinioTlsEnabled(tlsEnabled),
    ]);
    return !responses.contains(false);
  } catch (e) {
    return false;
  }
}

Future<bool> setMinioEndpoint(String endpoint) async {
  return await setStringSetting(_MINIO_ENDPOINT, endpoint);
}

Future<String> getMinioEndpoint() async {
  return getStringSetting(_MINIO_ENDPOINT);
}

Future<bool> setMinioPort(int port) async {
  return setIntSetting(_MINIO_PORT, port);
}

Future<int> getMinioPort() async {
  return getIntSetting(_MINIO_PORT);
}

Future<bool> setMinioAccessKey(String accessKey) async {
  return setStringSetting(_MINIO_ACCESS_KEY, accessKey);
}

Future<String> getMinioAccessKey() async {
  return getStringSetting(_MINIO_ACCESS_KEY);
}

Future<bool> setMinioSecretKey(String secretKey) async {
  return setStringSetting(_MINIOsECRET_KEY, secretKey);
}

Future<String> getMinioSecretKey() async {
  return getStringSetting(_MINIOsECRET_KEY);
}

Future<bool> setMinioTlsEnabled(bool enabled) async {
  return setBoolSetting(_MINIO_TLS_ENABLED, enabled);
}

Future<bool> getMinioTlsEnabled() async {
  return getBoolSetting(_MINIO_TLS_ENABLED);
}

