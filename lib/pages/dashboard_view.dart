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

class _DashboardViewState extends State<DashboardView> {
  String endpoint;
  String region;
  bool useTLS = false;
  int port;
  String bucket;
  List<Bucket> buckets;

  // final globalKey = GlobalKey<ScaffoldState>();

  initState() {
    super.initState();
    getMinioBucket().then((String bucket) {
      this.bucket = bucket;
    });
    getStorageDetails().then((storageDetails) {
      if (mounted) {
        setState(() {
          this.endpoint = storageDetails.item1;
          this.region = storageDetails.item2;
          this.port = storageDetails.item3;
          this.useTLS = storageDetails.item4;
          this.buckets = storageDetails.item5;
        });
      }
    });
  }

  Widget _cardWidget(String title, String highlightedContent,
      {Color highlightedContentColor = Colors.white}) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: TextStyle(
                color: LIGHT_GREY,
                fontWeight: FontWeight.w300,
                fontSize: 20,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: 10),
          Align(
            alignment: highlightedContent != null ? Alignment.centerLeft : Alignment.center,
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

  Widget _storageConnectionWidget(BuildContext context) {
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
                child: this._cardWidget('Bucket', this.bucket),
              ),
              VerticalDivider(color: DARK_GREY),
              Expanded(
                child: this._cardWidget('Endpoint', this.endpoint),
              ),
              VerticalDivider(color: DARK_GREY),
              Expanded(
                child: this._cardWidget('Port', this.port.toString()),
              ),
              VerticalDivider(color: DARK_GREY),
              Expanded(
                child: this._cardWidget('TLS', this.useTLS.toString(),
                    highlightedContentColor: this.useTLS
                        ? Theme.of(context).accentColor
                        : LIGHT_RED),
              ),
              VerticalDivider(color: DARK_GREY),
              Expanded(
                child: this._cardWidget('Region', this.region),
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
              this._storageConnectionWidget(context),
              // GridView.count(
              //   physics: BouncingScrollPhysics(),
              //   crossAxisCount: 2,
              //   padding: EdgeInsets.symmetric(
              //     vertical: 32,
              //     horizontal: 0,
              //   ),
              //   childAspectRatio: 2.0,
              //   children: List.generate(
              //     10,
              //     (index) => Card(
              //       clipBehavior: Clip.antiAlias,
              //       color: Theme.of(context).primaryColor,
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(10.0),
              //       ),
              //       elevation: 3,
              //       margin: EdgeInsets.all(10),
              //       child: Padding(
              //         padding: EdgeInsets.all(20),
              //         child: Text(
              //           'Lorem ipsum',
              //           style: TextStyle(
              //             color: Colors.white,
              //             fontWeight: FontWeight.w300,
              //             fontSize: 30,
              //           ),
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
