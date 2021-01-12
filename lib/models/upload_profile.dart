import 'dart:convert';

/// An [UploadProfile] captures metadata which are stored along with
/// the actual log data.
///
/// The idea is that one creates multiple profiles, e.g. one profile
/// per static / dynamic event. According to the current event /
/// location, a different profile can be activated while uploading
/// log files. The profile therefore captures information such as who
/// was driving the vehicle (driver), where the vehicle was driven
/// (name of the event or location), and potentially additional tags
/// such as a description of the race track (`rainy`, `dry`, `hot`)
/// or the purpose of the log files (e.g. `test in workshop`).
class UploadProfile {
  String name;
  String vehicle;
  List<String> drivers;
  List<String> eventOrLocation;
  List<String> tags;
  bool enabled;

  UploadProfile(
    this.name,
    this.vehicle,
    this.drivers,
    this.eventOrLocation,
    this.tags, {
    this.enabled = false,
  });

  Map<String, dynamic> toJson() => {
        'name': this.name,
        'vehicle': this.vehicle,
        'drivers': this.drivers,
        'eventOrLocation': this.eventOrLocation,
        'tags': this.tags,
        'enabled': this.enabled,
      };

  /// Transforms this [UploadProfile] into a JSON string.
  ///
  /// This method is intended to be used for creating the
  /// file `_metadata.json` while uploading log files to
  /// the remote storage. For this purpose, an additional
  /// upload timestamp is included. The value of
  /// [numberOfFiles] should contain the number of files
  /// which are about to be uploaded. This number is
  /// included in the JSON file, too. The information that
  /// this [UploadProfile] was enabled is unnecessary and
  /// therefore removed.
  String toJsonString(int numberOfFiles) {
    final map = this.toJson();
    map['uploadTimestampIso8601'] = DateTime.now().toIso8601String();
    map['numberOfFiles'] = numberOfFiles;
    map.remove('enabled');
    return jsonEncode(map);
  }

  UploadProfile.fromJson(Map<String, dynamic> json)
      : this.name = json['name'] as String,
        this.vehicle = json['vehicle'] as String,
        this.drivers = List.from(json['drivers']),
        this.eventOrLocation = List.from(json['eventOrLocation']),
        this.tags = List.from(json['tags']),
        this.enabled = json['enabled'] as bool;
}
