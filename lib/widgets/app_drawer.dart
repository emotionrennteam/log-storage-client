import 'dart:ui';

import 'package:log_storage_client/models/file_transfer_exception.dart';
import 'package:log_storage_client/utils/constants.dart';
import 'package:log_storage_client/utils/locator.dart';
import 'package:log_storage_client/utils/navigation_service.dart';
import 'package:log_storage_client/utils/constants.dart' as constants;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:log_storage_client/utils/progress_service.dart';
import 'package:log_storage_client/widgets/file_transfer_error_dialog.dart';

class AppDrawer extends StatefulWidget {
  final List<AppDrawerItem> appDrawerItems = [
    new AppDrawerItem(
      'Dashboard',
      Icons.dashboard_rounded,
      DashboardRoute,
    ),
    new AppDrawerItem(
      'Profiles',
      FontAwesomeIcons.userAlt,
      ProfilesRoute,
    ),
    new AppDrawerItem(
      'Local Log Files',
      FontAwesomeIcons.solidFolder,
      LocalLogFilesRoute,
    ),
    new AppDrawerItem(
      'Remote Log Files',
      FontAwesomeIcons.cloud,
      RemoteLogFilesRoute,
    ),
    new AppDrawerItem(
      'Settings',
      FontAwesomeIcons.cog,
      SettingsRoute,
    ),
  ];

  AppDrawer({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String _activeRouteName = DashboardRoute;
  double _progressValue = 0.0;
  bool _isInProgress = false;
  String _processName;
  List<FileTransferException> _errors = new List();
  Function _dialogSetState;

  @override
  initState() {
    super.initState();
    locator<ProgressService>().getProgressValueStream().listen((progressValue) {
      setState(() {
        this._progressValue = progressValue;
      });
    });
    locator<ProgressService>().getIsInProgressStream().listen((inProgress) {
      setState(() {
        this._isInProgress = inProgress;
      });
    });
    locator<ProgressService>().getProcessNameStream().listen((processName) {
      setState(() {
        this._processName = processName;
      });
    });
    locator<ProgressService>().getErrorMessagesStream().listen((error) {
      if (this._dialogSetState != null) {
        this._dialogSetState(() {
          setState(() {
            _errors.add(error);
          });
        });
      } else {
        setState(() {
          _errors.add(error);
        });
      }
    });
  }

  List<Widget> _buildAppDrawerItems(BuildContext context) {
    final appDrawerItems = List<Widget>();
    widget.appDrawerItems.asMap().forEach((index, element) {
      appDrawerItems.add(
        Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 10,
          ),
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              boxShadow: [
                BoxShadow(
                  color: this._activeRouteName == element.routeName
                      ? Theme.of(context).accentColor.withOpacity(0.5)
                      : Colors.transparent,
                  blurRadius: 30,
                  spreadRadius: 0,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Material(
              borderRadius: BorderRadius.circular(7),
              color: this._activeRouteName == element.routeName
                  ? Theme.of(context).accentColor
                  : Colors.transparent,
              child: InkWell(
                splashColor: Theme.of(context).accentColor,
                highlightColor: Colors.transparent,
                onTap: () {
                  setState(() {
                    this._activeRouteName = element.routeName;
                  });
                  locator<NavigationService>().navigateTo(element.routeName);
                },
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                    ),
                    SizedBox(
                      width: 30,
                      child: Align(
                        alignment: Alignment.center,
                        child: FaIcon(
                          element.icon,
                          color: constants.TEXT_COLOR,
                          size: 20,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      element.title,
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
    return appDrawerItems;
  }

  /// Opens a [FileTransferErrorDialog] to list file transfer errors (upload & download).
  void _showFileTransferErrorDialog() async {
    await showCupertinoModalPopup(
      context: context,
      filter: ImageFilter.blur(
        sigmaX: 2,
        sigmaY: 2,
      ),
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          // This additional setState() function is required to update the dialog's content.
          this._dialogSetState = setState;
          return FileTransferErrorDialog(
            this._errors,
            () => this._errors = List(),
          );
        });
      },
    );
    this._dialogSetState = null;
  }

  /// A widget that visualizes the current upload/download progress using a
  /// [LinearProgressIndicator], shows percentage of completion, and a name
  /// for the currently active file transfer ("Upload" respectively "Download").
  /// 
  /// This widget automatically positions itself out of the app's view after
  /// the file transfer completed.
  Widget _progressVisualization() {
    return AnimatedPositioned(
      curve: Curves.easeOutCubic,
      bottom: this._isInProgress ? 0 : -100,
      duration: Duration(
        milliseconds: this._isInProgress ? 100 : 1000,
      ),
      left: 0,
      child: Container(
        width: 310,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(7),
            topRight: Radius.circular(7),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Theme.of(context).canvasColor,
              blurRadius: 20,
              spreadRadius: 0,
              offset: Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          elevation: 10,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          color: Theme.of(context).primaryColor,
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 16,
                    ),
                    child: Text(
                      this._progressValue == 1.0
                          ? '${this._processName != null ? this._processName : ''} Completed'
                          : '${this._processName != null ? this._processName : ''} In Progress...',
                      style: TextStyle(
                        fontWeight: FontWeight.w300,
                        color: constants.TEXT_COLOR,
                        fontSize: 19,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(right: 16),
                      child: Text(
                        this._progressValue != null
                            ? '${(this._progressValue * 100).round()} %'
                            : '',
                        textAlign: TextAlign.right,
                        style: Theme.of(context).accentTextTheme.headline5,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(7),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Theme.of(context).accentColor.withOpacity(0.0),
                            blurRadius: 10,
                            spreadRadius: 5,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                      height: 7,
                      child: LinearProgressIndicator(
                        backgroundColor:
                            Theme.of(context).canvasColor.withOpacity(0.5),
                        value: this._progressValue,
                        valueColor: AlwaysStoppedAnimation(
                          Theme.of(context).accentColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Returns a button which shows whether there are any file transfer
  /// errors (upload/download errors).
  /// 
  /// The button automatically changes its color from green to red when at
  /// least one file transfer error occurred. The button is automatically
  /// disabled when there are no file transfer errors.
  Widget _fileTransferErrorButton() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: EdgeInsets.only(bottom: this._isInProgress ? 100 : 30),
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 10,
          ),
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              boxShadow: [
                BoxShadow(
                  color: this._errors == null || this._errors.length == 0
                      ? Theme.of(context).accentColor.withOpacity(0.5)
                      : LIGHT_RED,
                  blurRadius: 30,
                  spreadRadius: 0,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Material(
              borderRadius: BorderRadius.circular(7),
              color: this._errors == null || this._errors.length == 0
                  ? Theme.of(context).accentColor
                  : LIGHT_RED,
              child: InkWell(
                splashColor: this._errors == null || this._errors.length == 0
                    ? Theme.of(context).accentColor
                    : LIGHT_RED,
                highlightColor: Colors.transparent,
                onTap: this._errors == null || this._errors.length == 0
                    ? null
                    : _showFileTransferErrorDialog,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 30,
                      child: Align(
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.warning_amber_rounded,
                          color: TEXT_COLOR,
                          size: 30,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      '${this._errors.length} File Transfer Error${this._errors.length == 1 ? "" : "s"}',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
      ),
      width: 310,
      child: Stack(
        children: [
          ListView(
            children: this._buildAppDrawerItems(context),
          ),
          this._fileTransferErrorButton(),
          this._progressVisualization(),
        ],
      ),
    );
  }
}

class AppDrawerItem {
  final String title;
  final IconData icon;
  final String routeName;

  AppDrawerItem(this.title, this.icon, this.routeName);
}
