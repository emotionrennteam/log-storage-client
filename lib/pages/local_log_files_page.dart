import 'dart:async';
import 'dart:io';

import 'package:emotion/models/storage_object.dart';
import 'package:emotion/utils/constants.dart';
import 'package:emotion/utils/app_settings.dart';
import 'package:emotion/utils/minio_manager.dart';
import 'package:emotion/utils/utils.dart';
import 'package:emotion/widgets/app_drawer.dart';
import 'package:emotion/widgets/storage_object_table.dart';
import 'package:emotion/widgets/storage_object_table_header.dart';
import 'package:emotion/widgets/upload_progress_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:path/path.dart' as path;

class LocalLogFilesPage extends StatefulWidget {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  LocalLogFilesPage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _LocalLogFilesPageState();
}

class _LocalLogFilesPageState extends State<LocalLogFilesPage> {
  StreamController<double> _progressStreamController;
  bool _uploadInProgress = false;
  double _progress = 0.0;

  List<FileSystemEntity> _fileSystemEntities = [];
  Directory _monitoredDirectory;
  List<StorageObject> _storageObjects = List();

  Directory _currentDirectory;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    this._progressStreamController?.close();
    super.dispose();
  }

  void _navigateToDirectory(String absolutePath) {
    // Navigate to parent in the directory tree
    if (absolutePath == null) {
      setState(() {
        this._currentDirectory = Directory(
          getParentForPath(this._currentDirectory.path, path.separator),
        );
      });
    } else {
      // Navigate to child in the directory tree
      setState(() {
        this._currentDirectory = Directory(absolutePath);
      });
    }
    _loadStorageObjects();
  }

  void _init() async {
    var logFileDirectory = await getLogFileDirectoryPath();
    this._monitoredDirectory = new Directory(logFileDirectory);
    this._currentDirectory = this._monitoredDirectory;
    _loadStorageObjects();
  }

  void _loadStorageObjects() {
    _fileSystemEntities = this._currentDirectory.listSync(recursive: false);

    setState(() {
      this._storageObjects = this._fileSystemEntities.map((e) {
        final stats = e.statSync();
        return new StorageObject(
          e.path,
          isDirectory: e is Directory,
          lastModified: stats.modified,
          sizeInBytes: stats.size,
        );
      }).toList();
    });
  }

  void _uploadFiles() async {
    if (this._uploadInProgress) return;
    if (mounted) {
      setState(() {
        this._progressStreamController = StreamController<double>();
        _uploadInProgress = true;
      });
    }
    final streamSubscription =
        this._progressStreamController.stream.listen((progress) {
      if (mounted) {
        setState(() {
          this._progress = progress;
        });
      }
    });
    var credentials = await getStorageConnectionCredentials();
    await uploadFileSystemEntities(
      credentials,
      this._fileSystemEntities,
      this._monitoredDirectory,
      this._progressStreamController,
    );

    Future.delayed(Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          streamSubscription.cancel();
          this._progressStreamController.close();
          this._progressStreamController = null;
          this._uploadInProgress = false;
        });
      }
    });

    final uploadTriggerFile = File(
      path.join(
        this._monitoredDirectory.path,
        AUTO_UPLOAD_TRIGGER_FILE,
      ),
    );
    if (uploadTriggerFile.existsSync()) {
      uploadTriggerFile.deleteSync();
    }
  }

  /// A [FloatingActionButton] for triggering the upload of log files.
  /// This button is automatically disabled when an upload is in progress.
  Widget _uploadFAB() {
    return FloatingActionButton.extended(
      /// During upload, the FAB is disabled
      onPressed: this._uploadFiles,
      backgroundColor:
          this._uploadInProgress ? Colors.grey : Theme.of(context).accentColor,
      disabledElevation: 2,
      icon: Icon(
        Icons.cloud_upload,
        color: Colors.white,
      ),
      label: Text(
        'Upload',
        style: TextStyle(
          fontSize: 20,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: widget._scaffoldKey,
      floatingActionButton: this._uploadFAB(),
      body: Stack(
        children: <Widget>[
          Column(
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    AppDrawer(2),
                    Expanded(
                      child: Container(
                        // color: Color.fromRGBO(26, 26, 26, 1),
                        color: Theme.of(context).canvasColor,
                        padding: EdgeInsets.symmetric(
                          horizontal: 64,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(
                                  bottom: 32,
                                  top: 32,
                                ),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Local Log Files',
                                    style:
                                        Theme.of(context).textTheme.headline2,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              Center(
                                child: StorageObjectTableHeader(
                                  this._currentDirectory != null
                                      ? path.relative(
                                          this._currentDirectory.path,
                                          from: this._monitoredDirectory.path)
                                      : '',
                                  '',
                                  this._navigateToDirectory,
                                  (_) {},
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  child: StorageObjectTable(
                                    this._navigateToDirectory,
                                    (_) => {},
                                    this._storageObjects,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          this._progressStreamController != null
              ? UploadProgressToast(this._progress)
              : SizedBox(),
        ],
      ),
    );
  }
}
