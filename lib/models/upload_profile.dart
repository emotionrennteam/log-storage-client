/// An [UploadProfile] captures metadata which are stored along with
/// the actual log data.
/// 
/// The idea is that one creates multiple profiles, e.g. one profile
/// per static / dynamic event. According to the current event /
/// location, a different profile can be activated while uploading
/// log files. The profile therefore captures information such as who
/// was driving the vehicle (driver), where the vehicle was driven
/// (name of the event or location), and potentially additional notes
/// such as a description of the race track (rainy, dry, hot) or the
/// purpose of the log files (e.g. test in workshop).
class UploadProfile {
  String name;
  String driver;
  String eventOrLocation;
  String notes;
  bool enabled;
  // TODO: add timestamp

  UploadProfile(
    this.name,
    this.driver,
    this.eventOrLocation,
    this.notes, {
    this.enabled = false,
  });
}
