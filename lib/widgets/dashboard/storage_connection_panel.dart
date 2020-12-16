import 'package:flutter/material.dart';
import 'package:log_storage_client/models/storage_connection_credentials.dart';
import 'package:log_storage_client/utils/app_settings.dart' as appSettings;
import 'package:log_storage_client/utils/constants.dart' as constants;
import 'package:log_storage_client/utils/storage_manager.dart';

/// A widget that executes a dynamic analysis of the app settings by trying
/// to establish a connection to the storage system with the current app
/// settings.
class StorageConnectionPanel extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _StorageConnectionPanelState();
}

class _StorageConnectionPanelState extends State<StorageConnectionPanel>
    with SingleTickerProviderStateMixin {
  bool _connectionError = true;
  String _connectionErrorMessage;
  AnimationController _animationController;
  StorageConnectionCredentials _storageConnectionCredentials;

  @override
  void initState() {
    super.initState();

    this._animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    appSettings.getStorageConnectionCredentials().then((credentials) {
      if (mounted) {
        setState(() {
          this._storageConnectionCredentials = credentials;
        });
        this._checkStorageConnection(this._storageConnectionCredentials);
      }
    });
  }

  @override
  void dispose() {
    this._animationController.dispose();
    super.dispose();
  }

  void _checkStorageConnection(StorageConnectionCredentials credentials) async {
    if (credentials == null) {
      this._animationController.forward();
      Future.delayed(Duration(seconds: 1), () {
        if (mounted) this._animationController.reset();
      });
      return;
    }

    this._animationController.repeat();
    validateConnection(credentials).then((result) {
      Future.delayed(Duration(seconds: 1), () {
        if (mounted) {
          this._animationController.reset();
          setState(() {
            this._connectionError = !result.item1;
            this._connectionErrorMessage = result.item2;
          });
        }
      });
    }).catchError((error) {
      Future.delayed(Duration(seconds: 1), () {
        if (mounted) {
          this._animationController.reset();
          setState(() {
            this._connectionError = true;
            this._connectionErrorMessage = (error as Exception).toString();
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(constants.BORDER_RADIUS_MEDIUM),
        boxShadow: [
          BoxShadow(
            color: this._connectionError
                ? constants.LIGHT_RED.withOpacity(0.8)
                : Theme.of(context).accentColor.withOpacity(0.8),
            blurRadius: 30,
            spreadRadius: 0,
            offset: Offset(0, 3),
          ),
        ],
        color: this._connectionError
            ? constants.DARK_RED
            : Theme.of(context).accentColor,
      ),
      duration: Duration(seconds: 1),
      child: Material(
        type: MaterialType.transparency,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(constants.BORDER_RADIUS_MEDIUM),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          splashColor: Colors.white,
          onTap: () {
            this._checkStorageConnection(this._storageConnectionCredentials);
          },
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(40, 20, 30, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Storage Connection',
                          style: TextStyle(
                            color: constants.TEXT_COLOR,
                            fontWeight: FontWeight.w300,
                            fontSize: 20,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(
                          width: 32,
                        ),
                        new AnimatedBuilder(
                          animation: this._animationController,
                          builder: (context, widget) {
                            return new Transform.rotate(
                              angle: this._animationController.value * 6.3,
                              child: widget,
                            );
                          },
                          child: Icon(
                            Icons.refresh,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: AnimatedOpacity(
                        duration: Duration(seconds: 1),
                        curve: Curves.easeOutCirc,
                        opacity:
                            this._animationController.isAnimating ? 0.0 : 1.0,
                        child: Text(
                          this._connectionError ? 'ERROR' : 'SUCCESS',
                          style: TextStyle(
                            color: constants.TEXT_COLOR,
                            fontWeight: FontWeight.w400,
                            fontSize: 30,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: AnimatedOpacity(
                        duration: Duration(seconds: 1),
                        curve: Curves.easeOutCirc,
                        opacity:
                            this._animationController.isAnimating ? 0.0 : 1.0,
                        child: Text(
                          this._connectionErrorMessage ?? '\n',
                          style: TextStyle(
                            color: constants.TEXT_COLOR,
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
