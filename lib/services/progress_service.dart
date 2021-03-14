import 'dart:async';
import 'package:log_storage_client/models/file_transfer_exception.dart';

/// This service is intended to collect/provide information on download
/// and upload progress.
class ProgressService {
  StreamController<double> _progressValueController = StreamController();
  StreamController<bool> _isInProgressController = StreamController.broadcast();
  StreamController<String> _processNameController = StreamController();
  StreamController<FileTransferException> _errorMessagesController =
      StreamController();

  /// This bool value is used to store the latest value of the [_isInProgressController].
  bool _lastestValueOfIsInProgress = false;

  /// For creating progress events.
  ///
  /// The parameter [processName] is displayed on the progress panel next to the
  /// progress value, e.g. "Upload" or "Download".
  StreamSink<double> startProgressStream(String processName) {
    this._processNameController.sink.add(processName);
    this._isInProgressController.sink.add(true);
    this._lastestValueOfIsInProgress = true;

    // Adding "null" to the progressValueController will make the progress indicator
    // show an indeterminate progress. Indeterminate progress indicators do
    // not have a specific value at each point in time and instead indicate that
    // progress is being made without indicating how much progress remains.
    this._progressValueController.sink.add(null);

    return this._progressValueController.sink;
  }

  Future<void> endProgressStream() async {
    this._progressValueController.sink.add(1.0);
    await Future.delayed(Duration(seconds: 5), () {
      this._isInProgressController.sink.add(false);
      this._lastestValueOfIsInProgress = false;
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

  /// Getter to retrieve the latest info whether a file transfer
  /// is currently in progress.
  ///
  /// This getter function somehow represents a duplicate because
  /// it emits the latest value of [_isInProgressController].
  /// Nevertheless, this getter is required because when listening
  /// to a stream, one cannot read the latest value and therefore
  /// new listeners cannot reliably determine whether a file transfer
  /// is in progress.
  bool isInProgress() => this._lastestValueOfIsInProgress;

  /// Stream that emits events with the name of the currently active process (e.g. 'Download' or 'Upload').
  Stream<String> getProcessNameStream() {
    return this._processNameController?.stream;
  }

  /// Sink for emitting error messages (e.g. listing files that couldn't be uploaded).
  StreamSink<FileTransferException> getErrorMessagesSink() {
    return this._errorMessagesController?.sink;
  }

  /// Stream that emits error messages (e.g. listing files that couldn't be uploaded).
  Stream<FileTransferException> getErrorMessagesStream() {
    return this._errorMessagesController?.stream;
  }
}
