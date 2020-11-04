import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:log_storage_client/models/storage_connection_credentials.dart';
import 'package:log_storage_client/utils/app_settings.dart';
import 'package:log_storage_client/utils/constants.dart';
import 'package:log_storage_client/utils/storage_manager.dart';
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
  AnimationController _animationController;
  String _bucket;
  List<Bucket> _availableBuckets;
  ScrollController _bucketsScrollController = ScrollController();
  final DateFormat _bucketsCreationDateformat = DateFormat.yMMMMd('en_US');
  bool _connectionError = true;
  String _connectionErrorMessage;
  String _endpoint;
  String _port;
  String _region;
  bool _useTLS = false;
  bool _connectionCredentialsAreValid;

  @override
  initState() {
    super.initState();

    getStorageBucket().then((String bucket) {
      this._bucket = bucket == null || bucket.isEmpty ? '-' : bucket;
    });
    getStorageConnectionCredentials().then((credentials) {
      if (mounted) {
        setState(() {
          this._endpoint =
              credentials.endpoint == null ? '-' : credentials.endpoint;
          this._port =
              credentials.port == null ? '-' : credentials.port.toString();
          this._useTLS =
              credentials.tlsEnabled == null ? false : credentials.tlsEnabled;
        });
      }
      this._connectionCredentialsAreValid = credentials.isValid();
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
            this._availableBuckets = result.item4;
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
            child: highlightedContent == null
                ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(LIGHT_GREY),
                  )
                : Text(
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
        borderRadius: BorderRadius.circular(BORDER_RADIUS_MEDIUM),
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
          borderRadius: BorderRadius.circular(BORDER_RADIUS_MEDIUM),
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
      height: 140,
      child: Material(
        borderRadius: BorderRadius.circular(BORDER_RADIUS_MEDIUM),
        color: Theme.of(context).primaryColor,
        child: Padding(
          padding: EdgeInsets.all(30),
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
                child: this._textPanel('Port', this._port),
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

  Widget _bucketsPanel(BuildContext context) {
    // Jumps to the bottom after 200 milliseconds and then scrolls back
    // to the top. Goal: show the user that the list of buckets is scrollable.
    Future.delayed(Duration(milliseconds: 200), () {
      _bucketsScrollController.jumpTo(
        _bucketsScrollController.position.maxScrollExtent,
      );
      Future.delayed(Duration(milliseconds: 50), () {
        _bucketsScrollController.animateTo(
          _bucketsScrollController.position.minScrollExtent,
          duration: Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
        );
      });
    });

    return Container(
      child: Material(
        borderRadius: BorderRadius.circular(BORDER_RADIUS_MEDIUM),
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
                      height: this._availableBuckets == null
                          ? 100
                          : this._availableBuckets.length <= 5
                              ? 100
                              : 300,
                      child: Stack(
                        children: [
                          this._availableBuckets == null
                              ? Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        LIGHT_GREY),
                                  ),
                                )
                              : SizedBox(),
                          DraggableScrollbar.rrect(
                            controller: _bucketsScrollController,
                            backgroundColor: DARK_GREY,
                            heightScrollThumb: 40,
                            child: ListView.builder(
                              controller: _bucketsScrollController,
                              padding: EdgeInsets.only(right: 20),
                              itemCount: this._availableBuckets != null
                                  ? this._availableBuckets.length
                                  : 0,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    this._availableBuckets[index].name,
                                    style: TextStyle(
                                      color: TEXT_COLOR,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 20,
                                    ),
                                    textAlign: (this._availableBuckets !=
                                                null &&
                                            this._availableBuckets.isNotEmpty)
                                        ? TextAlign.left
                                        : TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                  trailing: Text(
                                    'created on ' +
                                        this._bucketsCreationDateformat.format(
                                              this
                                                  ._availableBuckets[index]
                                                  .creationDate,
                                            ),
                                    style: TextStyle(
                                      color: TEXT_COLOR.withAlpha(150),
                                      fontWeight: FontWeight.w400,
                                      fontSize: 20,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _regionPanel() {
    return Container(
      child: Material(
        borderRadius: BorderRadius.circular(BORDER_RADIUS_MEDIUM),
        color: Theme.of(context).primaryColor,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
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

  Widget _configurationValidationPanel() {
    return Container(
      child: Material(
        borderRadius: BorderRadius.circular(BORDER_RADIUS_MEDIUM),
        color: Theme.of(context).primaryColor,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                height: 16,
              ),
              this._textPanel(
                'Valid Configuration',
                this._connectionCredentialsAreValid.toString(),
              ),
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
        horizontal: 32,
        vertical: 42,
      ),
      child: StaggeredGridView.countBuilder(
        crossAxisCount: 6,
        crossAxisSpacing: 32,
        mainAxisSpacing: 32,
        itemCount: 5,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return this._configurationPanel(context);
          } else if (index == 1) {
            return this._storageConnectionPanel();
          } else if (index == 2) {
            return this._regionPanel();
          } else if (index == 3) {
            return this._bucketsPanel(context);
          } else if (index == 4) {
            return this._configurationValidationPanel();
          }
          return SizedBox();
        },
        staggeredTileBuilder: (int index) {
          if (index == 0) {
            return StaggeredTile.fit(6);
          } else if (index == 1) {
            return StaggeredTile.fit(3);
          } else if (index == 2) {
            return StaggeredTile.fit(3);
          } else if (index == 3) {
            if (MediaQuery.of(context).size.width > 1500) {
              return StaggeredTile.fit(4);
            }
            return StaggeredTile.fit(6);
          } else if (index == 4) {
            return StaggeredTile.fit(2);
          }
          return StaggeredTile.count(1, 1);
        },
      ),
    );
  }
}
