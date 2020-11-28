import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:log_storage_client/utils/constants.dart' as constants;

/// A generic widget to visualize data in the [DashboardView].
class DashboardPanel extends StatelessWidget {
  final String title;
  final String content;
  final Color titleColor;
  final Color highlightedContentColor;

  DashboardPanel({
    this.title,
    this.content,
    this.titleColor = constants.LIGHT_GREY,
    this.highlightedContentColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
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
            alignment:
                content != null ? Alignment.centerLeft : Alignment.center,
            child: content == null
                ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      constants.LIGHT_GREY,
                    ),
                  )
                : Text(
                    content != null ? content : '-',
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
}
