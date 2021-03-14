/// Represents suggestions / entries for the auto completion of [UploadProfile]s.
class UploadProfileSuggestions {
  Set<String> drivers = Set();
  Set<String> eventsOrLocations = Set();
  Set<String> tags = Set();
  Set<String> vehicles = Set();

  UploadProfileSuggestions();

  UploadProfileSuggestions.fromJson(Map<String, dynamic> json) {
    this.drivers = Set.from(json['drivers']);
    this.eventsOrLocations = Set.from(json['eventsOrLocations']);
    this.tags = Set.from(json['tags']);
    this.vehicles = Set.from(json['vehicles']);
  }

  Map<String, dynamic> toJson() => {
        'drivers': this.drivers.toList(),
        'eventsOrLocations': this.eventsOrLocations.toList(),
        'tags': this.tags.toList(),
        'vehicles': this.vehicles.toList(),
      };

}
