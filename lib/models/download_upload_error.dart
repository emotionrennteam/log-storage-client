class DownloadUploadError {
  final String filePath;
  final String errorMessage;
  final DateTime timestamp;

  DownloadUploadError(
    this.filePath,
    this.errorMessage,
    this.timestamp,
  );
}
