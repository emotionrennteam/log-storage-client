import 'package:flutter/material.dart';
import 'package:log_storage_client/models/upload_profile.dart';
import 'package:log_storage_client/services/upload_profile_service.dart';
import 'package:log_storage_client/utils/constants.dart' as constants;
import 'package:log_storage_client/utils/app_settings.dart' as AppSettings;
import 'package:log_storage_client/utils/locator.dart';
import 'package:log_storage_client/widgets/emotion_design_button.dart';

/// An [AlertDialog] for selecting / confirming the [UploadProfile].
///
/// The built [AlertDialog] will pop with a boolean value as the resulting future.
/// [True] indicates that the user confirmed the selection. [False] indicates that
/// the user clicked on the cancel button. You can access the result this way:
/// ```dart
/// final result = await showDialog(
///   context: context,
///   builder: (_) => UploadProfileEditDialog(),
/// );
/// ```
/// The result will be null, if the user clicks on the cancel
/// button or dismisses the dialog.
/// The result will contain the resulting [UploadProfile], if
/// the user clicks on the save button.
class ConfirmUploadProfileSelectionDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ConfirmUploadProfileSelectionDialogState();
}

class _ConfirmUploadProfileSelectionDialogState
    extends State<ConfirmUploadProfileSelectionDialog> {
  List<UploadProfile> _uploadProfiles;
  UploadProfile _activeUploadProfile;

  @override
  void initState() {
    super.initState();
    AppSettings.getUploadProfiles().then((uploadProfiles) {
      setState(() {
        this._uploadProfiles = uploadProfiles;
        this._activeUploadProfile =
            uploadProfiles.where((p) => p.enabled).first;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Upload Profile Selection'),
      actionsPadding: EdgeInsets.only(right: 20, bottom: 20),
      actions: [
        EmotionDesignButton(
          verticalPadding: 17,
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.only(right: 5),
                child: Icon(
                  Icons.upload_file,
                  color: Theme.of(context).accentColor,
                ),
              ),
              Text(
                'Upload',
                style: TextStyle(
                  color: Theme.of(context).accentColor,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          onPressed: () => Navigator.of(context).pop<bool>(true),
        ),
        EmotionDesignButton(
          color: Theme.of(context).canvasColor,
          child: Text(
            'Cancel',
            style: Theme.of(context).textTheme.button,
          ),
          onPressed: () => Navigator.of(context).pop<bool>(false),
        ),
      ],
      backgroundColor: Theme.of(context).primaryColor,
      content: Container(
        constraints: BoxConstraints(
          maxHeight: 125,
        ),
        width: 500,
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Please confirm the upload profile:'),
            SizedBox(
              height: 20,
            ),
            SizedBox(
              height: 16,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: BorderRadius.circular(
                  constants.BORDER_RADIUS_LARGE,
                ),
              ),
              child: DropdownButton<String>(
                dropdownColor: constants.DARK_GREY,
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
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        profile.name,
                        style: Theme.of(context).textTheme.subtitle1,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
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
                  await AppSettings.setUploadProfiles(this._uploadProfiles);
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
          ],
        ),
      ),
    );
  }
}
