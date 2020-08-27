import 'dart:async';
import 'dart:io';

import 'package:emotion/pages/settings_page.dart';
import 'package:emotion/utils/app_settings.dart';
import 'package:emotion/utils/minio_manager.dart';
import 'package:emotion/widgets/app_drawer.dart';
import 'package:emotion/widgets/file_system_entity_table.dart';
import 'package:emotion/widgets/settings/textfield_setting.dart';
import 'package:emotion/widgets/upload_progress_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

import '../models/extended_file_system_event.dart';

class LocalLogFilesPage extends StatefulWidget {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  LocalLogFilesPage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _LocalLogFilesPageState();
}

class _LocalLogFilesPageState extends State<LocalLogFilesPage> {
  final _dateFormatter = new DateFormat('HH:mm:ss');
  // final _scrollController = ScrollController(initialScrollOffset: 0.0);
  StreamController<double> _progressStreamController;
  double _progress = 0.0;
  bool _uploadInProgress = false;

  List<FileSystemEntity> _fileSystemEntities = [];
  List<ExtendedFileSystemEvent> _fileSystemEvents = [];
  StreamSubscription _fileEventStreamSubscription;
  Directory _monitoredDirectory;

  @override
  void initState() {
    super.initState();

    this._loadLogFileDirectory().then((success) {
      if (success) {
        this._initializeFileSystemWatcher();
      }
    });
  }

  @override
  void dispose() {
    _fileEventStreamSubscription.cancel();
    this._progressStreamController.close();
    super.dispose();
  }

  Future<bool> _loadLogFileDirectory() async {
    try {
      var logFileDirectory = await getLogFileDirectoryPath();
      this._monitoredDirectory = new Directory(logFileDirectory);

      if (this._monitoredDirectory.existsSync()) {
        return true;
      }

      widget._scaffoldKey.currentState.hideCurrentSnackBar();
      widget._scaffoldKey.currentState.showSnackBar(
        SnackBar(
          action: SnackBarAction(
            label: 'CONFIGURE',
            onPressed: () => Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (BuildContext context, _, __) {
                  return SettingsPage();
                },
              ),
            ),
          ),
          content: Text(
              'The specified log file directory does not exist or cannot be accessed.'),
        ),
      );
      return false;
    } on FileSystemException catch (e) {
      debugPrint(e.toString());
    }

    return false;
  }

  void _initializeFileSystemWatcher() async {
    try {
      // https://api.dart.dev/stable/2.8.4/dart-io/FileSystemEntity-class.html
      Stream<FileSystemEvent> eventStream =
          this._monitoredDirectory.watch(recursive: true);
      _fileEventStreamSubscription = eventStream.listen((event) {
        if (mounted) {
          setState(() {
            this._fileSystemEvents.add(
                  ExtendedFileSystemEvent(
                    fileSystemEvent: event,
                    timestamp: DateTime.now(),
                  ),
                );
          });
          debugPrint('## EVENT: $event');
        }
      });

      setState(() {
        _fileSystemEntities =
            this._monitoredDirectory.listSync(recursive: true);
      });
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  Widget _monitoredDirectoryWidget() {
    return TextFieldSetting('Log File Directory', 's', null, null);
    return Card(
      // color: Theme.of(context).accentColor,
      color: Color.fromRGBO(40, 40, 40, 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'Monitored Directory:',
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  this._monitoredDirectory != null
                      ? this._monitoredDirectory.absolute.path
                      : '',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  /// A [FloatingActionButton] for triggering the upload of log files.
  /// This button is automatically disabled when an upload is in progress.
  Widget _uploadFAB() {
    return FloatingActionButton.extended(
      /// During upload, the FAB is disabled
      onPressed: this._uploadInProgress
          ? null
          : () async {
              setState(() {
                this._progressStreamController = StreamController<double>();
                _uploadInProgress = true;
              });
              final streamSubscription =
                  this._progressStreamController.stream.listen((progress) {
                setState(() {
                  this._progress = progress;
                });
              });
              var credentials = await getStorageConnectionCredentials();
              await uploadFileSystemEntities(
                credentials,
                this._fileSystemEntities,
                this._monitoredDirectory,
                this._progressStreamController,
              );

              Future.delayed(Duration(seconds: 5), () {
                setState(() {
                  streamSubscription.cancel();
                  this._progressStreamController.close();
                  this._progressStreamController = null;
                  this._uploadInProgress = false;
                });
              });
            },
      backgroundColor: this._uploadInProgress
          ? Colors.grey
          : Theme.of(context).accentColor,
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
    // Future.delayed(Duration(milliseconds: 50), () {
    // this._scrollController.jumpTo(
    //       _scrollController.position.maxScrollExtent,
    //     );
    // });

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
                        color: Color.fromRGBO(26, 26, 26, 1),
                        padding: EdgeInsets.symmetric(
                          horizontal: 32,
                        ),
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(15),
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
                                // _monitoredDirectoryWidget(),
                                // SizedBox(height: 20),
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 5,
                                    ),
                                    child: FileSystemEntityTable(
                                      this._monitoredDirectory,
                                      this._fileSystemEntities,
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
