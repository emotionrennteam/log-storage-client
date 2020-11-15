import 'dart:async';

/// Service for monitoring changes to the currently selected/active
/// [UploadProfile].
class UploadProfileService {
  StreamController<void> _uploadProfileChangeController =
      StreamController.broadcast();

  StreamSink<void> getUploadProfileChangeSink() {
    return this._uploadProfileChangeController.sink;
  }

  Stream<void> getUploadProfileChangeStream() {
    return this._uploadProfileChangeController.stream;
  }

}
