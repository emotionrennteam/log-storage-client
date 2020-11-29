class StorageConnectionCredentials {
  final String endpoint;
  final int port;
  final String region;
  final String bucket;
  final String accessKey;
  final String secretKey;
  final bool tlsEnabled;

  StorageConnectionCredentials(this.endpoint, this.port, this.region,
      this.bucket, this.accessKey, this.secretKey, this.tlsEnabled);
}
