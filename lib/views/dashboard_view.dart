import 'package:flutter/foundation.dart';
import 'package:log_storage_client/models/storage_connection_credentials.dart';
import 'package:log_storage_client/utils/app_settings.dart';
import 'package:log_storage_client/utils/constants.dart';
import 'package:log_storage_client/utils/minio_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:log_storage_client/utils/utils.dart';
import 'package:minio/models.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class DashboardView extends StatefulWidget {
  DashboardView({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView>
    with SingleTickerProviderStateMixin {
  String _bucket;
  List<Bucket> _buckets;
  bool _connectionError = true;
  String _connectionErrorMessage;
  String _endpoint;
  int port;
  String _region;
  bool _useTLS = false;
  AnimationController _animationController;

  @override
  initState() {
    super.initState();

    getMinioBucket().then((String bucket) {
      this._bucket = bucket;
    });
    getStorageConnectionCredentials().then((credentials) {
      if (mounted) {
        setState(() {
          this._endpoint = credentials.endpoint;
          this.port = credentials.port;
          this._useTLS = credentials.tlsEnabled;
        });
      }
      this._checkStorageConnection(credentials: credentials);
    }).catchError((error) {
      setState(() {
        this._connectionError = true;
        this._connectionErrorMessage = error.toString();
      });
      Scaffold.of(context).showSnackBar(
        getSnackBar(error.toString(), true),
      );
    });

    this._animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
  }

  @override
  dispose() {
    this._animationController.dispose();
    super.dispose();
  }

  void _checkStorageConnection(
      {StorageConnectionCredentials credentials}) async {
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
            this._region = result.item3;
            this._buckets = result.item4;
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

  Widget _textPanel(String title, String highlightedContent,
      {Color titleColor = LIGHT_GREY,
      Color highlightedContentColor = Colors.white}) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: titleColor,
              fontWeight: FontWeight.w300,
              fontSize: 20,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(
            height: 10,
          ),
          Align(
            alignment: highlightedContent != null
                ? Alignment.centerLeft
                : Alignment.center,
            child: Text(
              highlightedContent != null ? highlightedContent : '-',
              style: TextStyle(
                color: highlightedContentColor,
                fontWeight: FontWeight.w400,
                fontSize: 30,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _storageConnectionPanel() {
    return AnimatedContainer(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: this._connectionError
                ? LIGHT_RED.withOpacity(0.8)
                : Theme.of(context).accentColor.withOpacity(0.8),
            blurRadius: 30,
            spreadRadius: 0,
            offset: Offset(0, 3),
          ),
        ],
        color: this._connectionError ? DARK_RED : Theme.of(context).accentColor,
      ),
      duration: Duration(seconds: 1),
      child: Material(
        type: MaterialType.transparency,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          splashColor: Colors.white,
          onTap: () {
            this._checkStorageConnection();
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
                            color: TEXT_COLOR,
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
                            color: TEXT_COLOR,
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
                          this._connectionErrorMessage != null
                              ? this._connectionErrorMessage
                              : '\n',
                          style: TextStyle(
                            color: TEXT_COLOR,
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

  Widget _configurationPanel(BuildContext context) {
    return Container(
      height: 120,
      child: Material(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).primaryColor,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: this._textPanel('Bucket', this._bucket),
              ),
              VerticalDivider(color: DARK_GREY),
              Expanded(
                child: this._textPanel('Endpoint', this._endpoint),
              ),
              VerticalDivider(color: DARK_GREY),
              Expanded(
                child: this._textPanel('Port', this.port.toString()),
              ),
              VerticalDivider(color: DARK_GREY),
              Expanded(
                child: this._textPanel('TLS', this._useTLS.toString(),
                    highlightedContentColor:
                        (this._useTLS != null) && (this._useTLS)
                            ? Theme.of(context).accentColor
                            : LIGHT_RED),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bucketsAndRegionPanel(BuildContext context) {
    var bucketsString = '';
    if (this._buckets == null || this._buckets.isEmpty) {
      bucketsString = '-';
    } else {
      for (var i = 0; i < this._buckets.length; i++) {
        bucketsString += this._buckets[i].name;
        if (i != this._buckets.length - 1) {
          bucketsString += ', ';
        }
      }
    }

    return Container(
      child: Material(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).primaryColor,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available Buckets',
                      style: TextStyle(
                        color: LIGHT_GREY,
                        fontWeight: FontWeight.w300,
                        fontSize: 20,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Container(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          bucketsString,
                          style: TextStyle(
                            color: TEXT_COLOR,
                            fontWeight: FontWeight.w400,
                            fontSize: 30,
                          ),
                          textAlign: (this._buckets != null &&
                                  this._buckets.isNotEmpty)
                              ? TextAlign.left
                              : TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Divider(color: DARK_GREY),
              SizedBox(
                height: 16,
              ),
              this._textPanel('Region', this._region),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 42,
      ),
      child: StaggeredGridView.countBuilder(
        crossAxisCount: 4,
        crossAxisSpacing: 32,
        mainAxisSpacing: 32,
        itemCount: 3,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return this._configurationPanel(context);
          } else if (index == 1) {
            return this._storageConnectionPanel();
          } else if (index == 2) {
            return this._bucketsAndRegionPanel(context);
          }
          return SizedBox();
        },
        staggeredTileBuilder: (int index) {
          if (index == 0) {
            return StaggeredTile.fit(4);
          } else if (index == 1) {
            return StaggeredTile.fit(2);
          } else if (index == 2) {
            return StaggeredTile.fit(2);
          }
          return StaggeredTile.count(1, 1);
        },
      ),
    );
  }
}
