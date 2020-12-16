import 'package:log_storage_client/services/auto_upload_service.dart';
import 'package:log_storage_client/services/navigation_service.dart';
import 'package:get_it/get_it.dart';
import 'package:log_storage_client/services/progress_service.dart';
import 'package:log_storage_client/services/upload_profile_service.dart';

/// Allows to locate singleton instances of services.
GetIt locator = GetIt.instance;

/// Registers [NavigationService], [ProgressService], and [UploadProfileService]
/// as a singletons.
void setupLocator() {
  locator.registerLazySingleton(() => NavigationService());
  locator.registerLazySingleton(() => ProgressService());
  locator.registerLazySingleton(() => UploadProfileService());
  locator.registerLazySingleton(() => AutoUploadService());
}
