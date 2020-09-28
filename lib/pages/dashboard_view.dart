import 'package:emotion/models/storage_connection_credentials.dart';
import 'package:emotion/utils/app_settings.dart';
import 'package:emotion/utils/constants.dart';
import 'package:emotion/utils/minio_manager.dart';
import 'package:emotion/widgets/app_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:minio/models.dart';

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
    this._animationController.forward();

    // Reset animation controller after 1 second so that the user can click on the
    // refresh icon again and the animation will restart.
    Future.delayed(
      Duration(seconds: 1),
      () {
        if (mounted) this._animationController.reset();
      },
    );

    if (credentials == null) {
      credentials = await getStorageConnectionCredentials();
    }
    validateConnection(credentials).then((result) {
      if (mounted) {
        setState(() {
          this._connectionError = !result.item1;
          this._connectionErrorMessage = result.item2;
          this._region = result.item3;
          this._buckets = result.item4;
        });
      }
    }).catchError((error) {
      if (mounted) {
        setState(() {
          this._connectionError = true;
          this._connectionErrorMessage = (error as Exception).toString();
        });
      }
    });
  }

  Widget _cardWidget(String title, String highlightedContent,
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
          SizedBox(height: 10),
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

  Widget _storageConnectionWidget() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
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
      ),
      clipBehavior: Clip.antiAlias,
      child: AnimatedContainer(
        duration: Duration(seconds: 1),
        color: this._connectionError ? DARK_RED : Theme.of(context).accentColor,
        child: Material(
          type: MaterialType.transparency,
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
                              this._animationController.isAnimating ? 1.0 : 0.0,
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
                      this._connectionErrorMessage != null
                          ? Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: Text(
                                this._connectionErrorMessage,
                                style: TextStyle(
                                  color: TEXT_COLOR,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 15,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 3,
                              ),
                            )
                          : SizedBox(height: 50),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _configurationWidget(BuildContext context) {
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
                child: this._cardWidget('Bucket', this._bucket),
              ),
              VerticalDivider(color: DARK_GREY),
              Expanded(
                child: this._cardWidget('Endpoint', this._endpoint),
              ),
              VerticalDivider(color: DARK_GREY),
              Expanded(
                child: this._cardWidget('Port', this.port.toString()),
              ),
              VerticalDivider(color: DARK_GREY),
              Expanded(
                child: this._cardWidget('TLS', this._useTLS.toString(),
                    highlightedContentColor: this._useTLS
                        ? Theme.of(context).accentColor
                        : LIGHT_RED),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppLayout(
        appDrawerCurrentIndex: 0,
        view: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              this._configurationWidget(context),
              SizedBox(
                height: 32,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        _storageConnectionWidget(),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [],
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
}
