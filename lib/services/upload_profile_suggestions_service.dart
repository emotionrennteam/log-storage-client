import 'dart:async';
import 'dart:convert';

import 'package:log_storage_client/models/storage_object.dart';
import 'package:log_storage_client/models/upload_profile.dart';
import 'package:log_storage_client/models/upload_profile_suggestions.dart';
import 'package:log_storage_client/utils/constants.dart' as constants;
import 'package:log_storage_client/utils/i_app_settings.dart';
import 'package:log_storage_client/utils/locator.dart';
import 'package:log_storage_client/utils/storage_manager.dart'
    as StorageManager;

/// A service which provides suggestions / entries for the auto completion
/// of [UploadProfile]s.
///
/// Suggestions are based on historical user input and stored as a separate
/// JSON file on the S3 storage system. During initialization, this service
/// fetches the existing JSON file from the S3 storage system to fill its
/// [UploadProfileSuggestions]. After editing an [UploadProfile], the
/// function `addSuggestionsFromUploadProfile()` collects new user input
/// and updates the JSON file on the S3 storage system. This implementation
/// might cause "lost updates" (as typically referenced in SQL databases)
/// because the existing JSON file is downloaded only once at app start.
class UploadProfileSuggestionsService {
  IAppSettings _appSettings = locator<IAppSettings>();

  UploadProfileSuggestions _suggestions = UploadProfileSuggestions();

  UploadProfileSuggestionsService();

  Future<UploadProfileSuggestionsService> init() async {
    try {
      final credentials =
          await this._appSettings.getStorageConnectionCredentials();

      final byteList =
          await StorageManager.downloadObjectFromRemoteStorageAsByteList(
        credentials,
        StorageObject(constants.UPLOAD_PROFILE_SUGGESTIONS_FILE),
      );
      this._suggestions = UploadProfileSuggestions.fromJson(
        jsonDecode(utf8.decode(byteList)),
      );
    } on Exception {
      this._suggestions = UploadProfileSuggestions();
    }

    return this;
  }

  void addSuggestionsFromUploadProfile(UploadProfile uploadProfile) async {
    if (uploadProfile.drivers != null) {
      this._suggestions.drivers.addAll(uploadProfile.drivers);
    }
    if (uploadProfile.eventOrLocation != null) {
      this._suggestions.eventsOrLocations.addAll(uploadProfile.eventOrLocation);
    }
    if (uploadProfile.tags != null) {
      this._suggestions.tags.addAll(uploadProfile.tags);
    }
    if (uploadProfile.vehicle != null && uploadProfile.vehicle.isNotEmpty) {
      this._suggestions.vehicles.add(uploadProfile.vehicle);
    }

    try {
      final suggestionsJSON = jsonEncode(this._suggestions);
      final credentials =
          await this._appSettings.getStorageConnectionCredentials();
      await StorageManager.uploadObjectToRemoteStorage(
        credentials,
        constants.UPLOAD_PROFILE_SUGGESTIONS_FILE,
        suggestionsJSON,
      );
    } on Exception {
      // Ignore
    }
  }

  List<String> getDriverSuggestions(String query) {
    if (this._suggestions != null) {
      return this._findMatchingValues(this._suggestions.drivers, query);
    }
    return List.empty();
  }

  List<String> getVehicleSuggestions(String query) {
    if (this._suggestions != null) {
      return this._findMatchingValues(this._suggestions.vehicles, query);
    }
    return List.empty();
  }

  List<String> getEventOrLocationSuggestions(String query) {
    if (this._suggestions != null) {
      return this
          ._findMatchingValues(this._suggestions.eventsOrLocations, query);
    }
    return List.empty();
  }

  List<String> getTagSuggestions(String query) {
    if (this._suggestions != null) {
      return this._findMatchingValues(this._suggestions.tags, query);
    }
    return List.empty();
  }

  List<String> _findMatchingValues(Set<String> values, String query) {
    if (values == null || values.isEmpty) {
      return List.empty();
    }
    return values
        .where((value) => value.toLowerCase().contains(query))
        .toList();
  }
}
