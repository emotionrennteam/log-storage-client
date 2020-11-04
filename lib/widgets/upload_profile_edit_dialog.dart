import 'package:flutter/material.dart';
import 'package:log_storage_client/models/upload_profile.dart';
import 'package:log_storage_client/utils/constants.dart';
import 'package:log_storage_client/widgets/emotion_design_button.dart';
import 'package:log_storage_client/widgets/settings/textfield_setting.dart';

/// An [AlertDialog] for editing and creating [UploadProfile]s.
/// 
/// The built [AlertDialog] will pop with the edited/created
/// [UploadProfile] as the resulting future. You can access
/// the result this way:
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
class UploadProfileEditDialog extends StatelessWidget {
  final _profileNameController = new TextEditingController();
  final _profileNameFocusNode = new FocusNode();
  final _profileDriverController = new TextEditingController();
  final _profileDriverFocusNode = new FocusNode();
  final _profileEventController = new TextEditingController();
  final _profileEventFocusNode = new FocusNode();
  final _profileNotesController = new TextEditingController();
  final _profileNotesFocusNode = new FocusNode();

  /// You can optionally provide an instance of [UploadProfile]
  /// if you want to edit an existing [UploadProfile].
  UploadProfileEditDialog({UploadProfile uploadProfile}) {
    if (uploadProfile != null) {
      this._profileNameController.text = uploadProfile.name;
      this._profileDriverController.text = uploadProfile.driver;
      this._profileEventController.text = uploadProfile.eventOrLocation;
      this._profileNotesController.text = uploadProfile.notes;
    }
  }

  /// Builds an [AlertDialog] for creating/editing [UploadProfile]s.
  /// 
  /// Pops with the created / created instance of [UploadProfile] which is
  /// null, if the user canceled / dismissed the dialog. 
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).primaryColor,
      elevation: 20,
      title: Text('Create Upload Profile'),
      content: Container(
        width: 800,
        height: 500,
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            TextFieldSetting(
              'Name',
              'FSG Event Profile',
              _profileNameController,
              _profileNameFocusNode,
              'A name which uniquely identifies this\nprofile, e.g. Workshop, Test, or Event XY.',
            ),
            SizedBox(
              height: 16,
            ),
            TextFieldSetting(
              'Driver',
              'John Doe',
              _profileDriverController,
              _profileDriverFocusNode,
              'The name of the driver who was driving\nwhile these log files were recorded.',
            ),
            SizedBox(
              height: 16,
            ),
            TextFieldSetting(
              'Event / Location',
              'Nürnburgring',
              _profileEventController,
              _profileEventFocusNode,
              'The place / location or name of the\nevent where these log files were\nrecorded.',
            ),
            SizedBox(
              height: 16,
            ),
            TextFieldSetting(
              'Notes',
              'Track conditions, weather, etc.',
              _profileNotesController,
              _profileNotesFocusNode,
              'Additional notes that could describe\nthe weather, track conditions, etc.',
            ),
          ],
        ),
      ),
      contentPadding: EdgeInsets.fromLTRB(24, 20, 24, 10),
      buttonPadding: EdgeInsets.only(
        right: 24,
      ),
      actions: <Widget>[
        EmotionDesignButton(
          child: Text(
            'Save',
            style: Theme.of(context).textTheme.button,
          ),
          onPressed: () {
            Navigator.of(context).pop<UploadProfile>(
              UploadProfile(
                this._profileNameController.text,
                this._profileDriverController.text,
                this._profileEventController.text,
                this._profileNotesController.text,
              ),
            );
          },
        ),
        EmotionDesignButton(
          child: Text(
            'Cancel',
            style: TextStyle(
              color: LIGHT_RED,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop<UploadProfile>();
          },
        ),
      ],
    );
  }
}
