import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:log_storage_client/models/upload_profile.dart';
import 'package:log_storage_client/utils/constants.dart' as constants;
import 'package:log_storage_client/widgets/emotion_design_button.dart';
import 'package:log_storage_client/widgets/settings/chips_textfield_setting.dart';
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
  final List<String> namesOfExistingProfiles;
  final UploadProfile uploadProfile;
  final ScrollController _scrollController = ScrollController();

  /// You can optionally provide an instance of [UploadProfile]
  /// if you want to edit an existing [UploadProfile].
  UploadProfileEditDialog(this.namesOfExistingProfiles, {this.uploadProfile});

  @override
  State<StatefulWidget> createState() => _UploadProfileEditDialogState();
}

class _UploadProfileEditDialogState extends State<UploadProfileEditDialog> {
  final _formKey = GlobalKey<FormState>();
  String _vehicle;
  List<String> _drivers = [];
  List<String> _eventOrLocation = [];
  List<String> _tags = [];

  // TODO: load known vehicles, drivers, etc. from S3 caching file
  Set<String> _knownVehicles = {
    'ERT-08/19',
    'ERT-09/20',
  };
  Set<String> _knownDrivers = {
    'Fabian Langer',
    'Jens Hertfelder',
  };
  Set<String> _knownEventOrLocations = {
    'Aalen',
    'Nürnburgring',
    'Workshop',
  };
  Set<String> _knownTags = {
    'cold',
    'hot',
    'rain',
    'rainy',
    'rainy trackdrive',
    'rainy weather',
    'sunny',
    'thunderstorm',
  };

  @override
  initState() {
    super.initState();
    if (widget.uploadProfile != null) {
      widget._profileNameController.text = widget.uploadProfile.name;
      widget.namesOfExistingProfiles.remove(widget.uploadProfile.name);

      this._vehicle = widget.uploadProfile.vehicle;
      this._drivers = widget.uploadProfile.drivers;
      this._eventOrLocation = widget.uploadProfile.eventOrLocation;
      this._tags = widget.uploadProfile.tags;
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
        height: 600,
        padding: EdgeInsets.all(16),
        child: Form(
          key: this._formKey,
          child: DraggableScrollbar.rrect(
            controller: widget._scrollController,
            backgroundColor: constants.DARK_GREY,
            heightScrollThumb: 40,
            child: ListView(
              controller: widget._scrollController,
              padding: EdgeInsets.only(
                right: 20,
              ),
              children: [
                TextFieldSetting(
                  'Name *',
                  'FSG Event Profile',
                  widget._profileNameController,
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
                ChipsTextFieldSetting(
                  initialValues: this._vehicle != null ? [this._vehicle] : [],
                  title: 'Vehicle *',
                  hintText: 'ERT-08/19',
                  maxValues: 1,
                  onAutoComplete: (query) => this
                      ._knownVehicles
                      .where((tag) => tag.toLowerCase().contains(query))
                      .toList(),
                  onAddChip: (chip) {
                    setState(() {
                      this._vehicle = chip;
                    });
                  },
                  onRemoveChip: (chip) {
                    setState(() {
                      this._vehicle = null;
                    });
                  },
                  tooltipMessage:
                      'The name of the the vehicle. Type and then\npress ENTER ' +
                          'to add the vehicle\'s name. You\ncan only add one vehicle name.',
                ),
                SizedBox(
                  height: 16,
                ),
                ChipsTextFieldSetting(
                  initialValues: this._drivers,
                  title: 'Drivers *',
                  hintText: 'Sebastian Vettel',
                  onAutoComplete: (query) => this
                      ._knownDrivers
                      .where((tag) => tag.toLowerCase().contains(query))
                      .toList(),
                  onAddChip: (chip) {
                    setState(() {
                      this._drivers.add(chip);
                    });
                  },
                  onRemoveChip: (chip) {
                    setState(() {
                      this._drivers.remove(chip);
                    });
                  },
                  tooltipMessage:
                      'The name of the drivers who were driving\nwhile these log files were ' +
                          'recorded. Type\nand press ENTER to add multiple values.',
                ),
                SizedBox(
                  height: 16,
                ),
                ChipsTextFieldSetting(
                  initialValues: this._eventOrLocation,
                  title: 'Event / Location *',
                  hintText: 'Nürnburgring',
                  onAutoComplete: (query) => this
                      ._knownEventOrLocations
                      .where((tag) => tag.toLowerCase().contains(query))
                      .toList(),
                  onAddChip: (chip) {
                    setState(() {
                      this._eventOrLocation.add(chip);
                    });
                  },
                  onRemoveChip: (chip) {
                    setState(() {
                      this._eventOrLocation.remove(chip);
                    });
                  },
                  tooltipMessage:
                      'The place / location or name of the\nevent where these log files were\nrecorded. ' +
                          'Type and then press\nENTER to add multiple values.',
                ),
                SizedBox(
                  height: 16,
                ),
                ChipsTextFieldSetting(
                  initialValues: this._tags,
                  title: 'Tags',
                  hintText: 'Track conditions, weather, etc.',
                  onAutoComplete: (query) => this
                      ._knownTags
                      .where((tag) => tag.toLowerCase().contains(query))
                      .toList(),
                  onAddChip: (chip) {
                    setState(() {
                      this._tags.add(chip);
                    });
                  },
                  onRemoveChip: (chip) {
                    setState(() {
                      this._tags.remove(chip);
                    });
                  },
                  tooltipMessage:
                      'Additional notes that describe the event,\nweather, track conditions, etc. Type\n' +
                          'and then press ENTER to add multiple tags.',
                ),
              ],
            ),
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
            // TODO: fix form validation after adding chip input fields
            if (this._formKey.currentState.validate()) {
              Navigator.of(context).pop<UploadProfile>(
                UploadProfile(
                  widget._profileNameController.text,
                  this._vehicle,
                  this._drivers,
                  this._eventOrLocation,
                  this._tags,
                ),
              );
            }
          },
        ),
        EmotionDesignButton(
          child: Text(
            'Cancel',
            style: TextStyle(
              color: constants.LIGHT_RED,
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
