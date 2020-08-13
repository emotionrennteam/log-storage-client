import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// A small toast message that displays the upload progress on the bottom of the view.
class UploadProgressToast extends StatelessWidget {
  /// The progress of the upload as a value between 0 and 1.
  final double progressValue;

  UploadProgressToast(this.progressValue);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: Container(
          width: 400,
          height: 70,
          child: Material(
            elevation: 10,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        this.progressValue == 1.0
                            ? 'Upload Completed'
                            : 'Uploading Log Files...',
                        style: Theme.of(context).textTheme.headline5,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          '${(this.progressValue * 100).round()} %',
                          textAlign: TextAlign.right,
                          style: Theme.of(context).textTheme.headline5,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        minHeight: 6,
                        value: this.progressValue,
                        valueColor: AlwaysStoppedAnimation(
                          this.progressValue == 1.0
                              ? Colors.greenAccent.shade400
                              : Theme.of(context).accentColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
