import 'package:log_storage_client/models/storage_connection_credentials.dart';
import 'package:log_storage_client/models/upload_profile.dart';

abstract class IAppSettings {
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
  );

  Future<StorageConnectionCredentials> getStorageConnectionCredentials();

  Future<bool> setStorageBucket(String bucket);

  Future<String> getStorageBucket();

  Future<bool> setStorageEndpoint(String endpoint);

  Future<String> getStorageEndpoint();

  Future<bool> setStoragePort(int port);

  Future<int> getStoragePort();

  Future<bool> setStorageAccessKey(String accessKey);

  Future<String> getStorageAccessKey();

  Future<bool> setStorageSecretKey(String secretKey);

  Future<String> getStorageRegion();

  Future<bool> setStorageRegion(String region);

  Future<String> getStorageSecretKey();

  Future<bool> setStorageTlsEnabled(bool enabled);

  Future<bool> getStorageTlsEnabled();

  Future<bool> setLogFileDirectoryPath(String logFileDirectoryPath);

  Future<String> getLogFileDirectoryPath();

  Future<bool> setAutoUploadEnabled(bool enabled);

  Future<bool> getAutoUploadEnabled();

  Future<List<UploadProfile>> getUploadProfiles();

  Future<bool> setUploadProfiles(List<UploadProfile> uploadProfiles);

  Future<UploadProfile> getEnabledUploadProfile();
}
