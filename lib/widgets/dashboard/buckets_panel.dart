import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:log_storage_client/utils/constants.dart' as constants;
import 'package:minio/models.dart';

class BucketsPanel extends StatefulWidget {
  final List<Bucket> buckets;
  final DateFormat bucketCreationDateFormat = DateFormat.yMMMMd('en_US');
  final ScrollController bucketsScrollController = ScrollController();

  BucketsPanel({this.buckets});

  @override
  State<StatefulWidget> createState() => _BucketsPanelState();
}

class _BucketsPanelState extends State<BucketsPanel> {
  @override
  Widget build(BuildContext context) {
    // Jumps to the bottom after 200 milliseconds and then scrolls back
    // to the top. Goal: show the user that the list of buckets is scrollable.
    Future.delayed(Duration(milliseconds: 200), () {
      if (mounted) {
        widget.bucketsScrollController.jumpTo(
          widget.bucketsScrollController.position.maxScrollExtent,
        );
        Future.delayed(Duration(milliseconds: 50), () {
          if (mounted) {
            widget.bucketsScrollController.animateTo(
              widget.bucketsScrollController.position.minScrollExtent,
              duration: Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
            );
          }
        });
      }
    });

    return Container(
      child: Material(
        borderRadius: BorderRadius.circular(constants.BORDER_RADIUS_MEDIUM),
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
                        color: constants.LIGHT_GREY,
                        fontWeight: FontWeight.w300,
                        fontSize: 20,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Container(
                      height: widget.buckets == null
                          ? 100
                          : widget.buckets.length <= 5
                              ? 100
                              : 300,
                      child: Stack(
                        children: [
                          widget.buckets == null
                              ? Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      constants.LIGHT_GREY,
                                    ),
                                  ),
                                )
                              : SizedBox(),
                          DraggableScrollbar.rrect(
                            controller: widget.bucketsScrollController,
                            backgroundColor: constants.DARK_GREY,
                            heightScrollThumb: 40,
                            child: ListView.builder(
                              controller: widget.bucketsScrollController,
                              padding: EdgeInsets.only(right: 20),
                              itemCount: widget.buckets != null
                                  ? widget.buckets.length
                                  : 0,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    widget.buckets[index].name,
                                    style: TextStyle(
                                      color: constants.TEXT_COLOR,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 20,
                                    ),
                                    textAlign: (widget.buckets != null &&
                                            widget.buckets.isNotEmpty)
                                        ? TextAlign.left
                                        : TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                  trailing: Text(
                                    'created on ' +
                                        widget.bucketCreationDateFormat.format(
                                          widget.buckets[index].creationDate,
                                        ),
                                    style: TextStyle(
                                      color:
                                          constants.TEXT_COLOR.withAlpha(150),
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
}
