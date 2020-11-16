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
class UploadProfileEditDialog extends StatefulWidget {
  final _profileNameController = new TextEditingController();
  final _profileNameFocusNode = new FocusNode();
  final _profileDriverController = new TextEditingController();
  final _profileDriverFocusNode = new FocusNode();
  final _profileEventController = new TextEditingController();
  final _profileEventFocusNode = new FocusNode();
  final _profileNotesController = new TextEditingController();
  final _profileNotesFocusNode = new FocusNode();

  final List<String> namesOfExistingProfiles;
  final UploadProfile uploadProfile;

  /// You can optionally provide an instance of [UploadProfile]
  /// if you want to edit an existing [UploadProfile].
  UploadProfileEditDialog(this.namesOfExistingProfiles, {this.uploadProfile});

  @override
  State<StatefulWidget> createState() => _UploadProfileEditDialogState();
}

class _UploadProfileEditDialogState extends State<UploadProfileEditDialog> {
  final _formKey = GlobalKey<FormState>();

  @override
  initState() {
    super.initState();
    if (widget.uploadProfile != null) {
      widget._profileNameController.text = widget.uploadProfile.name;
      widget._profileDriverController.text = widget.uploadProfile.driver;
      widget._profileEventController.text =
          widget.uploadProfile.eventOrLocation;
      widget._profileNotesController.text = widget.uploadProfile.notes;
      widget.namesOfExistingProfiles.remove(widget.uploadProfile.name);
    }
  }

  /// Builds an [AlertDialog] for creating/editing [UploadProfile]s.
  ///
  /// Pops with the created / created instance of [UploadProfile] which is
  /// null, if the user canceled / dismissed the dialog.
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).canvasColor,
      buttonPadding: EdgeInsets.only(
        right: 24,
      ),
      contentPadding: EdgeInsets.fromLTRB(24, 20, 24, 20),
      elevation: 20,
      title: Text('Create Upload Profile'),
      content: Container(
        width: 800,
        height: 500,
        padding: EdgeInsets.all(16),
        child: Form(
          key: this._formKey,
          child: ListView(
            children: [
              TextFieldSetting(
                'Name *',
                'FSG Event Profile',
                widget._profileNameController,
                widget._profileNameFocusNode,
                'A name which uniquely identifies this\nprofile, e.g. Workshop, Test, or Event XY.',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'The profile\'s name must not be empty.';
                  }
                  if (widget.namesOfExistingProfiles.contains(value)) {
                    return 'A profile with the same name already exists.';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 16,
              ),
              TextFieldSetting(
                'Driver *',
                'John Doe',
                widget._profileDriverController,
                widget._profileDriverFocusNode,
                'The name of the driver who was driving\nwhile these log files were recorded.',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'The name of the driver must not be empty.';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 16,
              ),
              TextFieldSetting(
                'Event / Location *',
                'Nürnburgring',
                widget._profileEventController,
                widget._profileEventFocusNode,
                'The place / location or name of the\nevent where these log files were\nrecorded.',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'The event / location must not be empty.';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 16,
              ),
              TextFieldSetting(
                'Notes',
                'Track conditions, weather, etc.',
                widget._profileNotesController,
                widget._profileNotesFocusNode,
                'Additional notes that could describe\nthe weather, track conditions, etc.',
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        EmotionDesignButton(
          child: Text(
            'Save',
            style: Theme.of(context).textTheme.button,
          ),
          onPressed: () {
            if (this._formKey.currentState.validate()) {
              Navigator.of(context).pop<UploadProfile>(
                UploadProfile(
                  widget._profileNameController.text,
                  widget._profileDriverController.text,
                  widget._profileEventController.text,
                  widget._profileNotesController.text,
                ),
              );
            }
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
