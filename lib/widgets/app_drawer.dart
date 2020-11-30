import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:log_storage_client/models/file_transfer_exception.dart';
import 'package:log_storage_client/models/upload_profile.dart';
import 'package:log_storage_client/services/auto_upload_service.dart';
import 'package:log_storage_client/services/upload_profile_service.dart';
import 'package:log_storage_client/utils/app_settings.dart' as appSettings;
import 'package:log_storage_client/utils/constants.dart';
import 'package:log_storage_client/utils/locator.dart';
import 'package:log_storage_client/services/navigation_service.dart';
import 'package:log_storage_client/utils/constants.dart' as constants;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:log_storage_client/services/progress_service.dart';
import 'package:log_storage_client/widgets/dialogs/file_transfer_error_dialog.dart';

class AppDrawer extends StatefulWidget {
  final List<AppDrawerItem> appDrawerItems = [
    new AppDrawerItem(
      'Dashboard',
      Icons.dashboard_rounded,
      DashboardRoute,
    ),
    new AppDrawerItem(
      'Upload Profiles',
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
  List<UploadProfile> _uploadProfiles = [];
  UploadProfile _activeUploadProfile;
  bool _autoUploadEnabled = false;
  Timer _autoUploadTimer;
  bool _autoUploadBlink = false;

  @override
  initState() {
    super.initState();

    this._loadUploadProfiles();
    this._loadAutoUpload();

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
    locator<UploadProfileService>()
        .getUploadProfileChangeStream()
        .listen((_) => this._loadUploadProfiles());
  }

  @override
  void dispose() {
    this._autoUploadTimer?.cancel();
    super.dispose();
  }

  void _loadUploadProfiles() {
    appSettings.getUploadProfiles().then((profiles) {
      if (mounted) {
        setState(() {
          this._activeUploadProfile = profiles.where((p) => p.enabled).first;
          this._uploadProfiles = profiles;
        });
      }
    });
  }

  void _loadAutoUpload() {
    appSettings.getAutoUploadEnabled().then((autoUploadEnabled) {
      appSettings.getLogFileDirectoryPath().then((logFileDirectoryPath) {
        locator<AutoUploadService>().enableAutoUpload(
          Directory(logFileDirectoryPath),
        );
        if (mounted) {
          setState(() {
            this._autoUploadEnabled = autoUploadEnabled;
            this._autoUploadTimer =
                Timer.periodic(Duration(seconds: 1), (timer) {
              setState(() {
                this._autoUploadBlink = !this._autoUploadBlink;
              });
            });
          });
        }
      });
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
              borderRadius: BorderRadius.circular(BORDER_RADIUS_SMALL),
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
              borderRadius: BorderRadius.circular(BORDER_RADIUS_SMALL),
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

    setState(() {
      // Dummy to ensure that the UI refreshes after the user has clicked the "Clear Errors"
      // button of the FileTransferErrorDialog and closed the dialog.
    });
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
            topLeft: Radius.circular(BORDER_RADIUS_SMALL),
            topRight: Radius.circular(BORDER_RADIUS_SMALL),
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
                        borderRadius:
                            BorderRadius.circular(BORDER_RADIUS_SMALL),
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

  /// A widget consisting of a dropdown through which the user
  /// can see / select the currently enabled [UploadProfile].
  Widget _activeUploadProfileDropdown() {
    return Tooltip(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(BORDER_RADIUS_SMALL),
      ),
      message: 'Active Upload Profile',
      padding: EdgeInsets.all(12),
      preferBelow: false,
      textStyle: Theme.of(context).textTheme.subtitle1,
      verticalOffset: 25,
      waitDuration: Duration(milliseconds: 500),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Align(
          alignment: Alignment.center,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Theme.of(context).canvasColor,
              borderRadius: BorderRadius.circular(
                constants.BORDER_RADIUS_LARGE,
              ),
            ),
            width: 270,
            child: DropdownButton<String>(
              dropdownColor: DARK_GREY,
              elevation: 20,
              icon: Icon(
                Icons.expand_more,
                color: constants.TEXT_COLOR,
              ),
              iconSize: 30,
              isExpanded: true,
              items: this
                  ._uploadProfiles
                  .map<DropdownMenuItem<String>>((UploadProfile profile) {
                return DropdownMenuItem<String>(
                  child: Text(
                    profile.name,
                    style: Theme.of(context).textTheme.headline6,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  value: profile.name,
                );
              }).toList(),
              onChanged: (String selectedProfile) async {
                setState(() {
                  this._uploadProfiles.forEach((e) {
                    if (e.name == selectedProfile) {
                      e.enabled = true;
                      this._activeUploadProfile = e;
                    } else {
                      e.enabled = false;
                    }
                  });
                });
                await appSettings.setUploadProfiles(this._uploadProfiles);
                locator<UploadProfileService>()
                    .getUploadProfileChangeSink()
                    .add(null);
              },
              underline: Container(
                height: 0,
              ),
              value: this._activeUploadProfile == null
                  ? 'Loading ...'
                  : this._activeUploadProfile.name,
            ),
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
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 10, 20, 30),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(BORDER_RADIUS_SMALL),
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
          borderRadius: BorderRadius.circular(BORDER_RADIUS_SMALL),
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
    );
  }

  /// A non-interactive widget that is only visible when the auto upload of log files
  /// is enabled.
  Widget _autoUploadWidget() {
    if (!this._autoUploadEnabled) {
      return SizedBox();
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(BORDER_RADIUS_LARGE),
          color: Theme.of(context).canvasColor,
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
            ),
            Text(
              'Auto Upload Enabled',
              style: Theme.of(context).textTheme.headline6,
            ),
            Expanded(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.only(
                    top: 10,
                    right: 20,
                  ),
                  child: Container(
                    width: this._autoUploadBlink ? 10 : 0,
                    height: this._autoUploadBlink ? 10 : 0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                ),
              ),
            ),
          ],
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
            padding: EdgeInsets.only(
              top: 10,
            ),
            children: this._buildAppDrawerItems(context),
          ),
          AnimatedPositioned(
            bottom: this._isInProgress ? 50 : 0,
            height: 300,
            width: 310,
            curve: Curves.easeOut,
            duration: Duration(
              milliseconds: this._isInProgress ? 100 : 1000,
            ),
            child: ListView(
              reverse: true,
              children: <Widget>[
                this._fileTransferErrorButton(),
                this._autoUploadWidget(),
                this._activeUploadProfileDropdown(),
              ],
            ),
          ),
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
