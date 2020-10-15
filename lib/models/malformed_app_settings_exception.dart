class MalformedAppSettingsException implements Exception {
  final String message;

  MalformedAppSettingsException(this.message);

  @override
  String toString() {
    return this.message;
  }
}
