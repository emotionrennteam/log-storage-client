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

  bool isValid() {
    // TODO: extend validation by checking whether the bucket exists
    return !(this.endpoint == null ||
        this.endpoint.isEmpty ||
        this.port == null ||
        this.region == null ||
        this.region.isEmpty ||
        this.bucket == null ||
        this.bucket.isEmpty ||
        this.accessKey == null ||
        this.accessKey.isEmpty ||
        this.secretKey == null ||
        this.secretKey.isEmpty);
  }
}
