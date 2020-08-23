import 'dart:async';
import 'dart:io';

import 'package:emotion/utils/app_settings.dart';
import 'package:emotion/utils/minio_manager.dart';
import 'package:emotion/widgets/app_drawer.dart';
import 'package:emotion/widgets/upload_progress_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

import '../models/extended_file_system_event.dart';

class LocalLogFilesPage extends StatefulWidget {
  LocalLogFilesPage({Key key, this.title}) : super(key: key);

  final globalKey = GlobalKey<ScaffoldState>();
  final String title;

  @override
  State<StatefulWidget> createState() => new _LocalLogFilesPageState();
}

class _LocalLogFilesPageState extends State<LocalLogFilesPage> {
  final _dateFormatter = new DateFormat('HH:mm:ss');
  final _scrollController = ScrollController();
  StreamController<double> _progressStreamController;
  double _progress = 0.0;
  bool _uploadInProgress = false;

  List<FileSystemEntity> _fileSystemEntities = [];
  List<ExtendedFileSystemEvent> _fileSystemEvents = [];
  StreamSubscription _fileEventStreamSubscription;
  Directory _monitoredDirectory;

  _LocalLogFilesPageState() {
    this._monitoredDirectory =
        //new Directory('C:\\Users\\phili\\Downloads\\ERT-0819\\log');
        new Directory(
            'C:\\Users\\phili\\workspace\\emotion\\directoryToMonitor');
    if (!this._monitoredDirectory.existsSync()) {
      // TODO: handle exception
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeFileSystemWatcher();
  }

  @override
  void dispose() {
    _fileEventStreamSubscription.cancel();
    this._progressStreamController.close();
    super.dispose();
  }

  void _initializeFileSystemWatcher() async {
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
  }

  Widget _monitoredDirectoryWidget() {
    return Card(
      color: Theme.of(context).accentColor,
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
                  this._monitoredDirectory.absolute.path,
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

  Widget _fileSystemEventsWidget() {
    return Card(
      color: Colors.grey.shade100,
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
                  'File System Events',
                  style: TextStyle(
                    fontSize: 25,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 200,
                    color: Colors.grey.shade200,
                    child: ListView.builder(
                      itemCount: this._fileSystemEvents.length,
                      itemBuilder: (context, index) {
                        return this._fileSystemEventWidget(
                            this._fileSystemEvents[index]);
                      },
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      controller: _scrollController,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _fileSystemEventWidget(ExtendedFileSystemEvent event) {
    return ListTile(
      leading: Text(_dateFormatter.format(event.timestamp)),
      title: Text(
        event.fileSystemEvent.toString(),
        style: TextStyle(
          color: Theme.of(context).primaryColor,
        ),
      ),
      trailing: (event.fileSystemEvent.type == FileSystemEvent.create)
          ? Icon(Icons.add_circle_outline, color: Colors.teal)
          : (event.fileSystemEvent.type == FileSystemEvent.delete)
              ? Icon(Icons.remove_circle_outline, color: Colors.redAccent)
              : (event.fileSystemEvent.type == FileSystemEvent.modify)
                  ? Icon(Icons.mode_edit)
                  : (event.fileSystemEvent.type == FileSystemEvent.move)
                      ? Icon(Icons.compare_arrows)
                      : Icon(Icons.info_outline),
    );
  }

  Widget _listFilesWidget() {
    _fileSystemEntities = this._monitoredDirectory.listSync(recursive: true);

    return Card(
      elevation: 2,
      color: Colors.grey.shade100,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(children: <Widget>[
          Row(
            children: [
              Text(
                'Files',
                style: TextStyle(
                  fontSize: 25,
                ),
              ),
            ],
          ),
          Container(
            height: 300,
            width: MediaQuery.of(context).size.width - 10,
            child: ListView.builder(
              itemCount: _fileSystemEntities.length,
              itemBuilder: (context, index) =>
                  _fileSystemEntityWidget(_fileSystemEntities[index]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _fileSystemEntityWidget(FileSystemEntity fileSystemEntity) {
    final relativePath = path.relative(fileSystemEntity.path,
        from: this._monitoredDirectory.path);
    // Hide nested directories & files.
    if (relativePath.contains('\\')) {
      return SizedBox();
    }

    var iconData = Icons.insert_drive_file;
    if (fileSystemEntity is Directory) {
      iconData = Icons.folder;
    }
    return ListTile(
      leading: Icon(iconData, color: Theme.of(context).accentColor),
      title: Text(
        fileSystemEntity.path.split('\\').last,
        style: TextStyle(
          color: Theme.of(context).primaryColor,
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
          ? Colors.grey.shade200
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
    Future.delayed(Duration(milliseconds: 50), () {
      this._scrollController.jumpTo(
            _scrollController.position.maxScrollExtent,
          );
    });

    return Scaffold(
      key: widget.globalKey,
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
                        child: SingleChildScrollView(
                          physics: BouncingScrollPhysics(),
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.all(15),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  _monitoredDirectoryWidget(),
                                  SizedBox(height: 20),
                                  _fileSystemEventsWidget(),
                                  SizedBox(height: 20),
                                  _listFilesWidget(),
                                ],
                              ),
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
