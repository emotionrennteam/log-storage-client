class StorageConnectionCredentials {
  final String endpoint;
  final int port;
  final String accessKey;
  final String secretKey;
  final String bucket;
  final bool tlsEnabled;

  StorageConnectionCredentials(this.endpoint, this.port, this.accessKey,
      this.secretKey, this.bucket, this.tlsEnabled);
}
