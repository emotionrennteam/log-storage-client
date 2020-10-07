import 'dart:async';

import 'package:log_storage_client/models/download_upload_error.dart';

class ProgressService {
  StreamController<double> _progressValueController = StreamController();
  StreamController<bool> _isInProgressController = StreamController();
  StreamController<String> _processNameController = StreamController();
  StreamController<DownloadUploadError> _errorMessagesController =
      StreamController();

  /// For creating progress events.
  ///
  /// The parameter [processName] is displayed on the progress panel next to the
  /// progress value. The parameter [indeterminateProgress] determines the progress
  /// mode of the [LinearProgressIndicator]. Indeterminate progress indicators do
  /// not have a specific value at each point in time and instead indicate that
  /// progress is being made without indicating how much progress remains.
  StreamSink<double> startProgressStream(
    String processName,
    bool indeterminateProgress,
  ) {
    this._processNameController.sink.add(processName);
    if (indeterminateProgress) {
      this._progressValueController.sink.add(null);
    }
    this._isInProgressController.sink.add(true);

    return this._progressValueController.sink;
  }

  endProgressStream() {
    this._progressValueController.sink.add(1.0);
    Future.delayed(Duration(seconds: 5), () {
      this._isInProgressController.sink.add(false);
    });
  }

  /// Stream that emits the progress as double values (values within the range 0.0 and 1.0).
  Stream<double> getProgressValueStream() {
    return this._progressValueController?.stream;
  }

  /// Stream that emits whether there's currently an ongoing process (download/ upload).
  Stream<bool> getIsInProgressStream() {
    return this._isInProgressController?.stream;
  }

  /// Stream that emits events with the name of the currently active process (e.g. 'Download' or 'Upload').
  Stream<String> getProcessNameStream() {
    return this._processNameController?.stream;
  }

  /// Sink for emitting error messages (e.g. listing files that couldn't be uploaded).
  StreamSink<DownloadUploadError> getErrorMessagesSink() {
    return this._errorMessagesController?.sink;
  }

  /// Stream that emits error messages (e.g. listing files that couldn't be uploaded).
  Stream<DownloadUploadError> getErrorMessagesStream() {
    return this._errorMessagesController?.stream;
  }
}
