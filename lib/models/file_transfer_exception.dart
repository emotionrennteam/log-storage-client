abstract class FileTransferException {
  final String message;
  final String path;
  final DateTime timestamp;
  FileTransferException(this.message, this.path, this.timestamp);
}

class DownloadException extends FileTransferException implements Exception {
  DownloadException(String message, String path)
      : super(message, path, DateTime.now());

  @override
  String toString() {
    return 'Download failed due to: $message';
  }
}

class UploadException extends FileTransferException implements Exception {
  UploadException(String message, String path)
      : super(message, path, DateTime.now());

  @override
  String toString() {
    return 'Upload failed due to: $message';
  }
}
