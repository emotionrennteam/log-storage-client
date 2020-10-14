import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:log_storage_client/models/file_transfer_exception.dart';
import 'package:log_storage_client/utils/constants.dart';
import 'package:log_storage_client/widgets/emotion_design_button.dart';

class FileTransferErrorDialog extends StatelessWidget {
  final List<FileTransferException> errors;
  final Function clearErrorsCallback;

  final DateFormat _dateFormat = DateFormat('HH:mm');
  final _scrollController = ScrollController();

  /// An [AlertDialog] that displays upload or download errors in a scrollable [ListView].
  /// Each row contains the timestamp, the path to the file, and the reason / exception
  /// why the upload respectively download has failed.
  FileTransferErrorDialog(this.errors, this.clearErrorsCallback);

  @override
  Widget build(BuildContext context) {
    // Scrolls to the bottom after 200 milliseconds so that the user
    // automatically sees the latest error messages.
    Future.delayed(Duration(milliseconds: 200), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 800),
        curve: Curves.easeOutQuart,
      );
    });

    return AlertDialog(
      actionsPadding: EdgeInsets.only(right: 20, bottom: 20),
      actions: [
        EmotionDesignButton(
          verticalPadding: 17,
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.only(right: 5),
                child: Icon(
                  Icons.clear,
                  color: LIGHT_RED,
                ),
              ),
              Text(
                'Clear Errors',
                style: TextStyle(
                  color: LIGHT_RED,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          onPressed: () {
            this.clearErrorsCallback();
            Navigator.of(context).pop();
          },
        ),
        EmotionDesignButton(
          color: Theme.of(context).canvasColor,
          child: Text(
            'Close',
            style: Theme.of(context).textTheme.button,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
      title: Text('File Transfer Errors'),
      backgroundColor: Theme.of(context).primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(7),
      ),
      content: Container(
        clipBehavior: Clip.antiAlias,
        constraints: BoxConstraints(
          maxHeight: 500,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          borderRadius: BorderRadius.circular(10),
        ),
        height: this.errors.length.toDouble() * 70,
        width: 800,
        child: DraggableScrollbar.rrect(
          controller: _scrollController,
          backgroundColor: DARK_GREY,
          heightScrollThumb: 70,
          padding: EdgeInsets.all(10),
          child: ListView.builder(
            controller: _scrollController,
            itemCount: this.errors.length,
            itemBuilder: (context, index) {
              return Container(
                color: Theme.of(context).canvasColor,
                padding: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.only(right: 20),
                      child: Text(
                        this._dateFormat.format(
                              this.errors[index].timestamp?.toLocal(),
                            ),
                      ),
                    ),
                    Container(
                      width: 370,
                      child: Text(
                        this.errors[index].path,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        this.errors[index].toString(),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
